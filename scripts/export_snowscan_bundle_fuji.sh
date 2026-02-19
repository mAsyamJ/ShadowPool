#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# RetroPick - Snowscan Verification Bundle Generator (Fuji)
# Generates Standard JSON input + constructor args for each
# deployed contract, ready to paste into:
#   https://testnet.snowscan.xyz/verifyContract
# ============================================================

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ENV_FILE="${ENV_FILE:-.env.fuji}"
OUT_DIR="${OUT_DIR:-verify/fuji}"

CHAIN_ID="${CHAIN_ID:-43113}"
COMPILER_VERSION="${COMPILER_VERSION:-v0.8.24+commit.e11b9ed9}"

# ---- sanity checks ----
need() { command -v "$1" >/dev/null 2>&1 || { echo "ERROR: missing dependency: $1"; exit 1; }; }
need forge
need cast

if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: env file not found: $ENV_FILE"
  exit 1
fi

# shellcheck disable=SC1090
source "$ENV_FILE"

mkdir -p "$OUT_DIR"

# ---- required env vars for ctor args ----
req_env() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "ERROR: Missing $name in $ENV_FILE"
    exit 1
  fi
}

req_env SETTLEMENT_TOKEN
req_env CHAINLINK_FORWARDER
req_env OPERATOR
req_env MIN_CONFIDENCE
req_env PROTOCOL_FEE_BPS

# ---- helper: write standard json input ----
write_standard_json() {
  local address="$1"
  local fqname="$2"
  local out_json="$3"

  # Forge prints to stdout; we capture it
  # Important: pass compiler version to avoid "cache disabled" errors.
  forge verify-contract \
    --chain-id "$CHAIN_ID" \
    --compiler-version "$COMPILER_VERSION" \
    --show-standard-json-input \
    "$address" \
    "$fqname" \
    > "$out_json"
}

# ---- helper: constructor args encoder ----
# Writes ABI-encoded ctor args hex to a file (or empty if none).
write_ctor_args() {
  local key="$1"
  local out_file="$2"

  case "$key" in
    OracleCoordinator|SettlementRouter|FeePool|TreasuryPool|MarketPolicy|MarketDraftBoard)
      : > "$out_file"
      ;;

    ReportValidator)
      cast abi-encode "constructor(uint16)" "$MIN_CONFIDENCE" > "$out_file"
      ;;

    FeeManager)
      cast abi-encode "constructor(uint16)" "$PROTOCOL_FEE_BPS" > "$out_file"
      ;;

    ExecutionLedger)
      cast abi-encode "constructor(address)" "0x0000000000000000000000000000000000000000" > "$out_file"
      ;;

    MultiAssetVault)
      cast abi-encode "constructor(address)" "0x0000000000000000000000000000000000000000" > "$out_file"
      ;;

    CollateralVault)
      cast abi-encode "constructor(address,address)" "$SETTLEMENT_TOKEN" "0x0000000000000000000000000000000000000000" > "$out_file"
      ;;

    ChannelSettlement)
      # constructor(address collateralVault, address ledger, address operator)
      cast abi-encode "constructor(address,address,address)" \
        "0xe1557c8f239752a22278a5c55f0cb28b041d9fcd" \
        "0xe4d4187d6ca2c4ea36a05d3eb61a7a79da7f6d25" \
        "$OPERATOR" \
        > "$out_file"
      ;;

    MarketRegistry)
      # constructor(address collateralVault, address ledger)
      cast abi-encode "constructor(address,address)" \
        "0xe1557c8f239752a22278a5c55f0cb28b041d9fcd" \
        "0xe4d4187d6ca2c4ea36a05d3eb61a7a79da7f6d25" \
        > "$out_file"
      ;;

    CREReceiver)
      # constructor(address forwarder, address oracleCoordinator)
      cast abi-encode "constructor(address,address)" \
        "$CHAINLINK_FORWARDER" \
        "0xa30fa013c5cae93c2e75129cea669635e011d6f8" \
        > "$out_file"
      ;;

    DraftClaimManager)
      cast abi-encode "constructor(address)" \
        "0xa1a31b61748252d7e1f15b2f74de0ce99f1a296f" \
        > "$out_file"
      ;;

    LiquidityVaultFactory)
      cast abi-encode "constructor(address)" \
        "0xa1f7673d2677fb9e48c7a6295dd7cf44f8c0a212" \
        > "$out_file"
      ;;

    MarketFactory)
      # constructor(address forwarder, address marketRegistry)
      cast abi-encode "constructor(address,address)" \
        "$CHAINLINK_FORWARDER" \
        "0xdb8d890b9ae6a40d2838a508f7d2126cb42a36e4" \
        > "$out_file"
      ;;

    CREPublishReceiver)
      # constructor(address forwarder, address draftBoard, address draftClaimManager, address marketPolicy, address marketFactory)
      cast abi-encode "constructor(address,address,address,address,address)" \
        "$CHAINLINK_FORWARDER" \
        "0xa1a31b61748252d7e1f15b2f74de0ce99f1a296f" \
        "0x1ccccc54e0ce928b3fc04aa2ed4e012e7eaadde9" \
        "0x98f399081cbdb2eeb66c8c3c51f5ff592a045396" \
        "0x68d0e961fdfaf031323099a4680847321efbb7e5" \
        > "$out_file"
      ;;

    *)
      echo "ERROR: unknown ctor key: $key"
      exit 1
      ;;
  esac
}

# ---- contracts list: key|address|fqname ----
# Note: FQName should match your repo paths.
CONTRACTS=(
  "OracleCoordinator|0xA30Fa013c5CAe93C2e75129ceA669635e011d6F8|src/oracle/OracleCoordinator.sol:OracleCoordinator"
  "SettlementRouter|0x789daEE98ac0C8EEe220Dd768f0e2A05C66B983E|src/core/SettlementRouter.sol:SettlementRouter"
  "FeePool|0x59d2B7563bC7b80c3EcE9A3E616441e68ca158A6|src/fees/FeePool.sol:FeePool"
  "TreasuryPool|0x1723701b8143537e023b9C6165dAeF9A67125d43|src/fees/TreasuryPool.sol:TreasuryPool"
  "MarketPolicy|0x98f399081CbDB2eeB66c8c3c51F5fF592A045396|src/curation/MarketPolicy.sol:MarketPolicy"
  "MarketDraftBoard|0xa1A31B61748252D7E1f15B2F74de0ce99f1a296f|src/curation/MarketDraftBoard.sol:MarketDraftBoard"

  "ReportValidator|0xC6c31b73CE71B42aB45dd017061fcd5D9620a1bE|src/oracle/ReportValidator.sol:ReportValidator"
  "FeeManager|0xB9C04B35C64dc263809DaeA3233de0855b44a82D|src/fees/FeeManager.sol:FeeManager"
  "ExecutionLedger|0xE4d4187d6Ca2c4eA36A05d3eb61a7A79da7F6D25|src/execution/ExecutionLedger.sol:ExecutionLedger"
  "MultiAssetVault|0xf780caB68DE9800fd6b8ee6AEfc0b06A5F3181dB|src/execution/MultiAssetVault.sol:MultiAssetVault"
  "CollateralVault|0xe1557c8f239752A22278a5c55f0CB28b041D9fcd|src/execution/CollateralVault.sol:CollateralVault"
  "ChannelSettlement|0xa1F7673D2677FB9e48C7a6295DD7cF44F8c0A212|src/execution/ChannelSettlement.sol:ChannelSettlement"
  "MarketRegistry|0xdB8d890B9aE6A40D2838A508F7D2126cb42a36E4|src/core/MarketRegistry.sol:MarketRegistry"

  "CREReceiver|0xf427BC9e8C7004F394fa06147bf42aad1D516FdF|src/oracle/CREReceiver.sol:CREReceiver"
  "DraftClaimManager|0x1Ccccc54e0cE928b3FC04aA2Ed4E012E7EaAdDe9|src/curation/DraftClaimManager.sol:DraftClaimManager"
  "LiquidityVaultFactory|0xd895dD8547A0fC6214A7ce9D74B49F9b0601C362|src/curation/LiquidityVaultFactory.sol:LiquidityVaultFactory"
  "MarketFactory|0x68D0e961FdFAF031323099a4680847321eFBb7e5|src/core/MarketFactory.sol:MarketFactory"
  "CREPublishReceiver|0xEF0aebe656c82A6d070f904c0c31EE1B0B81fBB2|src/curation/CREPublishReceiver.sol:CREPublishReceiver"
)

echo "Output directory: $OUT_DIR"
echo "Env file:         $ENV_FILE"
echo "Chain ID:         $CHAIN_ID"
echo "Compiler:         $COMPILER_VERSION"
echo

# Ensure build artifacts exist (so JSON generation matches repo state)
echo "Building (must match deploy settings)..."
forge build >/dev/null
echo "Build OK"
echo

# Generate bundle
for entry in "${CONTRACTS[@]}"; do
  IFS="|" read -r key address fqname <<< "$entry"

  safe_key="$key"
  std_json="$OUT_DIR/${safe_key}.standard.json"
  ctor_file="$OUT_DIR/${safe_key}.ctorargs.txt"

  echo "==> $key"
  echo "    Address: $address"
  echo "    FQName:  $fqname"

  write_standard_json "$address" "$fqname" "$std_json"
  write_ctor_args "$key" "$ctor_file"

  echo "    Wrote:   $(basename "$std_json")"
  if [[ -s "$ctor_file" ]]; then
    echo "    Ctor:    $(cat "$ctor_file")"
  else
    echo "    Ctor:    (none)"
  fi
  echo
done

# Write a quick instruction markdown
cat > "$OUT_DIR/VERIFY_ON_SNOWSCAN.md" << 'MD'
# Verify on Snowscan (Fuji)

Go to:
https://testnet.snowscan.xyz/verifyContract

For each contract:

1) Contract Address: use the deployed address
2) Verify Method: Solidity (Standard-Json-Input)
3) Compiler Version: v0.8.24+commit.e11b9ed9
4) Optimization / Runs / viaIR / EVM Version: must match your Foundry deployment settings
5) Standard JSON Input: paste `<Contract>.standard.json`
6) Constructor Arguments: paste `<Contract>.ctorargs.txt` (leave empty if none)

Tip:
- If constructor arg field fails with `0x...`, try removing the `0x`.
MD

echo "Done. Bundle created at: $OUT_DIR"
echo "Open: $OUT_DIR/VERIFY_ON_SNOWSCAN.md"
