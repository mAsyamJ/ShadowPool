#!/usr/bin/env bash
set -euo pipefail

############################################
# RetroPick – Verify All (Avalanche Fuji 43113)
# Snowtrace backend via Routescan Etherscan-compatible endpoint.
#
# Fixes:
# - avoids broadcast parsing (no jq parse errors)
# - always provides --compiler-version (works even if cache is disabled)
############################################

CHAIN_ID="${CHAIN_ID:-43113}"
NETWORK_KIND="${NETWORK_KIND:-testnet}" # routescan: testnet/mainnet
VERIFIER_URL="${VERIFIER_URL:-https://api.routescan.io/v2/network/${NETWORK_KIND}/evm/${CHAIN_ID}/etherscan}"

# Routescan free tier: any string works (Foundry still requires a key argument)
ETHERSCAN_API_KEY="${ETHERSCAN_API_KEY:-verifyContract}"

ENV_FILE="${ENV_FILE:-.env.fuji}"
WATCH="${WATCH:-1}"     # 1 = --watch, 0 = no watch
RETRIES="${RETRIES:-8}"
SLEEP="${SLEEP:-10}"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

# required env for constructor args
: "${MIN_CONFIDENCE:?Missing MIN_CONFIDENCE in ${ENV_FILE}}"
: "${PROTOCOL_FEE_BPS:?Missing PROTOCOL_FEE_BPS in ${ENV_FILE}}"
: "${SETTLEMENT_TOKEN:?Missing SETTLEMENT_TOKEN in ${ENV_FILE}}"
: "${OPERATOR:?Missing OPERATOR in ${ENV_FILE}}"
: "${CHAINLINK_FORWARDER:?Missing CHAINLINK_FORWARDER in ${ENV_FILE}}"

echo "forge build (must match deploy settings)..."
forge build >/dev/null

# ---- compiler version (fix cache-disabled error) ----
# Pull compiler version from an artifact's metadata.
# metadata is a JSON string; we parse it to get .compiler.version
ARTIFACT_FOR_COMPILER="${ARTIFACT_FOR_COMPILER:-out/OracleCoordinator.sol/OracleCoordinator.json}"
if [[ ! -f "$ARTIFACT_FOR_COMPILER" ]]; then
  echo "Cannot find artifact to read compiler version: $ARTIFACT_FOR_COMPILER"
  echo "Set ARTIFACT_FOR_COMPILER=out/<Any>.sol/<Any>.json"
  exit 1
fi

COMP_VER_RAW="$(jq -r '.metadata' "$ARTIFACT_FOR_COMPILER" | jq -r '.compiler.version')"
# Etherscan-style expects leading 'v'
if [[ "$COMP_VER_RAW" == v* ]]; then
  COMPILER_VERSION="$COMP_VER_RAW"
else
  COMPILER_VERSION="v${COMP_VER_RAW}"
fi

echo "Verifier URL:        $VERIFIER_URL"
echo "Compiler version:    $COMPILER_VERSION"
echo "Chain ID:            $CHAIN_ID"
echo ""

base_verify_cmd() {
  local addr="$1"
  local fq="$2"
  local ctor_args="${3:-}"

  local cmd=(forge verify-contract
    --chain-id "$CHAIN_ID"
    --verifier-url "$VERIFIER_URL"
    --etherscan-api-key "$ETHERSCAN_API_KEY"
    --compiler-version "$COMPILER_VERSION"
  )

  if [[ "$WATCH" == "1" ]]; then
    cmd+=(--watch)
  fi

  if [[ -n "$ctor_args" ]]; then
    cmd+=("$addr" "$fq" --constructor-args "$ctor_args")
  else
    cmd+=("$addr" "$fq")
  fi

  "${cmd[@]}"
}

verify() {
  local addr="$1"
  local fq="$2"
  local ctor_args="${3:-}"

  echo ""
  echo "============================================================"
  echo "Address:  $addr"
  echo "FQName:   $fq"
  if [[ -n "$ctor_args" ]]; then
    echo "CtorArgs: $ctor_args"
  else
    echo "CtorArgs: (none)"
  fi
  echo "============================================================"

  local attempt=1
  while [[ "$attempt" -le "$RETRIES" ]]; do
    set +e
    base_verify_cmd "$addr" "$fq" "$ctor_args"
    rc=$?
    set -e

    if [[ "$rc" -eq 0 ]]; then
      echo "OK: verified $fq @ $addr"
      return 0
    fi

    echo "WARN: verify failed (attempt ${attempt}/${RETRIES}) for $fq @ $addr"
    echo "      sleeping ${SLEEP}s then retry..."
    sleep "$SLEEP"
    attempt=$((attempt + 1))
  done

  echo "FAIL: could not verify after ${RETRIES} attempts: $fq @ $addr"
  return 1
}

############################################
# Fuji addresses (your list)
############################################

# Execution lane
EXECUTION_LEDGER="0xE4d4187d6Ca2c4eA36A05d3eb61a7A79da7F6D25"
CHANNEL_SETTLEMENT="0xa1F7673D2677FB9e48C7a6295DD7cF44F8c0A212"
MULTI_ASSET_VAULT="0xf780caB68DE9800fd6b8ee6AEfc0b06A5F3181dB"
COLLATERAL_VAULT="0xe1557c8f239752A22278a5c55f0CB28b041D9fcd"
MARKET_REGISTRY="0xdB8d890B9aE6A40D2838A508F7D2126cb42a36E4"

# Fees
FEE_MANAGER="0xB9C04B35C64dc263809DaeA3233de0855b44a82D"
FEE_POOL="0x59d2B7563bC7b80c3EcE9A3E616441e68ca158A6"
TREASURY_POOL="0x1723701b8143537e023b9C6165dAeF9A67125d43"

# Oracle + routing
REPORT_VALIDATOR="0xC6c31b73CE71B42aB45dd017061fcd5D9620a1bE"
CRE_RECEIVER="0xf427BC9e8C7004F394fa06147bf42aad1D516FdF"
ORACLE_COORDINATOR="0xA30Fa013c5CAe93C2e75129ceA669635e011d6F8"
SETTLEMENT_ROUTER="0x789daEE98ac0C8EEe220Dd768f0e2A05C66B983E"

# Curation / publishing
MARKET_POLICY="0x98f399081CbDB2eeB66c8c3c51F5fF592A045396"
DRAFT_BOARD="0xa1A31B61748252D7E1f15B2F74de0ce99f1a296f"
DRAFT_CLAIM_MANAGER="0x1Ccccc54e0cE928b3FC04aA2Ed4E012E7EaAdDe9"
LIQUIDITY_VAULT_FACTORY="0xd895dD8547A0fC6214A7ce9D74B49F9b0601C362"
MARKET_FACTORY="0x68D0e961FdFAF031323099a4680847321eFBb7e5"
CRE_PUBLISH_RECEIVER="0xEF0aebe656c82A6d070f904c0c31EE1B0B81fBB2"

############################################
# NO constructor args
############################################
verify "$ORACLE_COORDINATOR" "src/oracle/OracleCoordinator.sol:OracleCoordinator"
verify "$SETTLEMENT_ROUTER"  "src/core/SettlementRouter.sol:SettlementRouter"
verify "$FEE_POOL"           "src/fees/FeePool.sol:FeePool"
verify "$TREASURY_POOL"      "src/fees/TreasuryPool.sol:TreasuryPool"
verify "$MARKET_POLICY"      "src/curation/MarketPolicy.sol:MarketPolicy"
verify "$DRAFT_BOARD"        "src/curation/MarketDraftBoard.sol:MarketDraftBoard"

############################################
# WITH constructor args (from your known wiring)
############################################

# ReportValidator(uint16 minConfidence)
ARGS="$(cast abi-encode "constructor(uint16)" "$MIN_CONFIDENCE")"
verify "$REPORT_VALIDATOR" "src/oracle/ReportValidator.sol:ReportValidator" "$ARGS"

# FeeManager(uint16 protocolFeeBps)
ARGS="$(cast abi-encode "constructor(uint16)" "$PROTOCOL_FEE_BPS")"
verify "$FEE_MANAGER" "src/fees/FeeManager.sol:FeeManager" "$ARGS"

# ExecutionLedger(address) -> address(0)
ARGS="$(cast abi-encode "constructor(address)" "0x0000000000000000000000000000000000000000")"
verify "$EXECUTION_LEDGER" "src/execution/ExecutionLedger.sol:ExecutionLedger" "$ARGS"

# MultiAssetVault(address) -> address(0)
ARGS="$(cast abi-encode "constructor(address)" "0x0000000000000000000000000000000000000000")"
verify "$MULTI_ASSET_VAULT" "src/execution/MultiAssetVault.sol:MultiAssetVault" "$ARGS"

# CollateralVault(address settlementToken, address) -> (SETTLEMENT_TOKEN, address(0))
ARGS="$(cast abi-encode "constructor(address,address)" "$SETTLEMENT_TOKEN" "0x0000000000000000000000000000000000000000")"
verify "$COLLATERAL_VAULT" "src/execution/CollateralVault.sol:CollateralVault" "$ARGS"

# ChannelSettlement(address collateralVault, address ledger, address operator)
ARGS="$(cast abi-encode "constructor(address,address,address)" "$COLLATERAL_VAULT" "$EXECUTION_LEDGER" "$OPERATOR")"
verify "$CHANNEL_SETTLEMENT" "src/execution/ChannelSettlement.sol:ChannelSettlement" "$ARGS"

# MarketRegistry(address collateralVault, address ledger)
ARGS="$(cast abi-encode "constructor(address,address)" "$COLLATERAL_VAULT" "$EXECUTION_LEDGER")"
verify "$MARKET_REGISTRY" "src/core/MarketRegistry.sol:MarketRegistry" "$ARGS"

# CREReceiver(address forwarder, address oracleCoordinator)
ARGS="$(cast abi-encode "constructor(address,address)" "$CHAINLINK_FORWARDER" "$ORACLE_COORDINATOR")"
verify "$CRE_RECEIVER" "src/oracle/CREReceiver.sol:CREReceiver" "$ARGS"

# DraftClaimManager(address draftBoard)
ARGS="$(cast abi-encode "constructor(address)" "$DRAFT_BOARD")"
verify "$DRAFT_CLAIM_MANAGER" "src/curation/DraftClaimManager.sol:DraftClaimManager" "$ARGS"

# LiquidityVaultFactory(address channelSettlement)
ARGS="$(cast abi-encode "constructor(address)" "$CHANNEL_SETTLEMENT")"
verify "$LIQUIDITY_VAULT_FACTORY" "src/curation/LiquidityVaultFactory.sol:LiquidityVaultFactory" "$ARGS"

# MarketFactory(address forwarder, address marketRegistry)
ARGS="$(cast abi-encode "constructor(address,address)" "$CHAINLINK_FORWARDER" "$MARKET_REGISTRY")"
verify "$MARKET_FACTORY" "src/core/MarketFactory.sol:MarketFactory" "$ARGS"

# CREPublishReceiver(address forwarder, address draftBoard, address draftClaimManager, address marketPolicy, address marketFactory)
ARGS="$(cast abi-encode "constructor(address,address,address,address,address)" "$CHAINLINK_FORWARDER" "$DRAFT_BOARD" "$DRAFT_CLAIM_MANAGER" "$MARKET_POLICY" "$MARKET_FACTORY")"
verify "$CRE_PUBLISH_RECEIVER" "src/curation/CREPublishReceiver.sol:CREPublishReceiver" "$ARGS"

echo ""
echo "Done."
