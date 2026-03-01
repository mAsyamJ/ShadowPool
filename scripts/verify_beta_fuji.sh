#!/usr/bin/env bash
set -euo pipefail

############################################
# RetroPick – Verify DeployBetaTestnet (Avalanche Fuji 43113)
# Uses Routescan Etherscan-compatible endpoint.
# Source scripts/env/.env.fuji (or .env) before running.
############################################

CHAIN_ID="${CHAIN_ID:-43113}"
NETWORK_KIND="${NETWORK_KIND:-testnet}"
VERIFIER_URL="${VERIFIER_URL:-https://api.routescan.io/v2/network/${NETWORK_KIND}/evm/${CHAIN_ID}/etherscan}"
ETHERSCAN_API_KEY="${ETHERSCAN_API_KEY:-verifyContract}"
ENV_FILE="${ENV_FILE:-scripts/env/.env.fuji}"
WATCH="${WATCH:-1}"
RETRIES="${RETRIES:-10}"
SLEEP="${SLEEP:-12}"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

: "${OPERATOR:?Missing OPERATOR}"
: "${CHAINLINK_FORWARDER:?Missing CHAINLINK_FORWARDER}"
: "${MIN_CONFIDENCE:?Missing MIN_CONFIDENCE}"
: "${PROTOCOL_FEE_BPS:?Missing PROTOCOL_FEE_BPS}"

# DeployBetaTestnet addresses (from broadcast)
MOCK_USDC="0x61c8d94ab8a729126a9FA41751FaD7F464604948"
FAUCET="0x4d74eCEc809D1DbbD8D4B9D1c26fFc8b8FbA9E89"
COLLATERAL_VAULT="0x792a065dD308A1Fc3d115Ea006b3093D8fBd7ea1"
CHANNEL_SETTLEMENT="0xFA5D0e64B0B21374690345d4A88a9748C7E22182"
DRAFT_BOARD="0x8a81759d0A4383E4879b0Ff298Bf60ff24be8302"
ORACLE_COORDINATOR="0x101053889dE4748763AA337685aA6842D3D4723C"
MARKET_REGISTRY="0x3235094A8826a6205F0A0b74E2370A4AC39c6Cc2"

echo "forge build..."
forge build >/dev/null

ARTIFACT_FOR_COMPILER="${ARTIFACT_FOR_COMPILER:-out/OracleCoordinator.sol/OracleCoordinator.json}"
COMP_VER_RAW="$(jq -r '.metadata' "$ARTIFACT_FOR_COMPILER" | jq -r '.compiler.version')"
[[ "$COMP_VER_RAW" == v* ]] && COMPILER_VERSION="$COMP_VER_RAW" || COMPILER_VERSION="v${COMP_VER_RAW}"

echo "Verifier URL:     $VERIFIER_URL"
echo "Compiler version: $COMPILER_VERSION"
echo ""

base_verify_cmd() {
  local addr="$1" fq="$2" ctor_args="${3:-}"
  local cmd=(forge verify-contract --chain-id "$CHAIN_ID" --verifier-url "$VERIFIER_URL" \
    --etherscan-api-key "$ETHERSCAN_API_KEY" --compiler-version "$COMPILER_VERSION")
  [[ "$WATCH" == "1" ]] && cmd+=(--watch)
  [[ -n "$ctor_args" ]] && cmd+=("$addr" "$fq" --constructor-args "$ctor_args") || cmd+=("$addr" "$fq")
  "${cmd[@]}"
}

verify() {
  local addr="$1" fq="$2" ctor_args="${3:-}"
  echo ""
  echo "============================================================"
  echo "Address: $addr  FQName: $fq"
  echo "============================================================"
  local attempt=1
  while [[ "$attempt" -le "$RETRIES" ]]; do
    if base_verify_cmd "$addr" "$fq" "$ctor_args"; then
      echo "OK: verified $fq @ $addr"
      return 0
    fi
    echo "WARN: attempt $attempt/$RETRIES failed, sleeping ${SLEEP}s..."
    sleep "$SLEEP"
    attempt=$((attempt + 1))
  done
  echo "FAIL: $fq @ $addr"
  return 1
}

# No constructor args
verify "0x61c8d94ab8a729126a9FA41751FaD7F464604948" "src/mockTest/token/MockUSDC.sol:MockUSDC"
verify "0xfefF1c0df050cDcD7dD6988749654A3a8948d746" "src/mockTest/token/MockDAI.sol:MockDAI"
verify "0xEcED85042Cbbb7756E0809e51aDf7B7a8d2851Aa" "src/mockTest/token/MockUSDT.sol:MockUSDT"
verify "0x08f7a4CFba8E8c944D33630faA2032b3B3b7c5e1" "src/mockTest/token/MockEURC.sol:MockEURC"
verify "0x8CA51cb13B91A6530429f154B8505c40BE0d7908" "src/mockTest/token/MockAVAX.sol:MockAVAX"
verify "0x952877CD34812E316CfE2324A632ad5c71d096EA" "src/mockTest/token/MockIDRX.sol:MockIDRX"
verify "0xB0d262089Cd5F66239298eb462D878fC50CBD2f3" "src/fees/FeePool.sol:FeePool"
verify "0x504313Da50e3E3d42769B96A16B9F58C2B84348a" "src/fees/TreasuryPool.sol:TreasuryPool"
verify "0xBfE28C2740C4b9Ee87299EF0a6590b21C0EBa4d0" "src/core/SettlementRouter.sol:SettlementRouter"
verify "0x101053889dE4748763AA337685aA6842D3D4723C" "src/oracle/OracleCoordinator.sol:OracleCoordinator"
verify "0x041584444a592d9c9Dbd7D1EDc110D63643408b5" "src/curation/MarketPolicy.sol:MarketPolicy"
verify "0x8a81759d0A4383E4879b0Ff298Bf60ff24be8302" "src/curation/MarketDraftBoard.sol:MarketDraftBoard"
verify "0x9DB5b69A6EdCC433e56C3C96e770A737a4b13555" "src/execution/MarketRiskManager.sol:MarketRiskManager"

# With constructor args
ARGS="$(cast abi-encode "constructor(address)" "$OPERATOR")"
verify "$FAUCET" "src/mockTest/faucet/Faucet.sol:Faucet" "$ARGS"

ARGS="$(cast abi-encode "constructor(string)" "https://api.retropick.xyz/outcome/{id}.json")"
verify "0x9B413811ecfD0e0679A7Ba785de44E15E7482044" "src/execution/OutcomeToken1155.sol:OutcomeToken1155" "$ARGS"

ARGS="$(cast abi-encode "constructor(address)" "0x0000000000000000000000000000000000000000")"
verify "0x71EEA55f90c028aEE2b0F0785d015ea4e9165aBF" "src/execution/MultiAssetVault.sol:MultiAssetVault" "$ARGS"

ARGS="$(cast abi-encode "constructor(address,address)" "$MOCK_USDC" "0x0000000000000000000000000000000000000000")"
verify "$COLLATERAL_VAULT" "src/execution/CollateralVault.sol:CollateralVault" "$ARGS"

ARGS="$(cast abi-encode "constructor(address,address,address)" "$COLLATERAL_VAULT" "0x0000000000000000000000000000000000000000" "$OPERATOR")"
verify "$CHANNEL_SETTLEMENT" "src/execution/ChannelSettlement.sol:ChannelSettlement" "$ARGS"

ARGS="$(cast abi-encode "constructor(address,address)" "$COLLATERAL_VAULT" "0x0000000000000000000000000000000000000000")"
verify "$MARKET_REGISTRY" "src/core/MarketRegistry.sol:MarketRegistry" "$ARGS"

ARGS="$(cast abi-encode "constructor(uint16)" "$PROTOCOL_FEE_BPS")"
verify "0x40094a387A609b5B983CD7eC8Ce3Ac44Ccbca1Db" "src/fees/FeeManager.sol:FeeManager" "$ARGS"

ARGS="$(cast abi-encode "constructor(uint16)" "$MIN_CONFIDENCE")"
verify "0x45Ac2A2473675D7baA7b24E07dc9A4053b005282" "src/oracle/ReportValidator.sol:ReportValidator" "$ARGS"

ARGS="$(cast abi-encode "constructor(address,address)" "$CHAINLINK_FORWARDER" "$ORACLE_COORDINATOR")"
verify "0x51c0680d8E9fFE2A2f6CC65e598280D617D6cAb7" "src/oracle/CREReceiver.sol:CREReceiver" "$ARGS"

ARGS="$(cast abi-encode "constructor(address)" "$DRAFT_BOARD")"
verify "0x0b7B98b10b2067a4918720Bc04f374c669B313d5" "src/curation/DraftClaimManager.sol:DraftClaimManager" "$ARGS"

ARGS="$(cast abi-encode "constructor(address)" "$CHANNEL_SETTLEMENT")"
verify "0x714518B11a4ce31C4fE42F0155473FD5158AD84e" "src/curation/LiquidityVaultFactory.sol:LiquidityVaultFactory" "$ARGS"

ARGS="$(cast abi-encode "constructor(address,address)" "$CHAINLINK_FORWARDER" "$MARKET_REGISTRY")"
verify "0x2f70602034854C14CBfD1F94C713f833d344d748" "src/core/MarketFactory.sol:MarketFactory" "$ARGS"

ARGS="$(cast abi-encode "constructor(address,address,address,address,address)" "$CHAINLINK_FORWARDER" "$DRAFT_BOARD" "0x0b7B98b10b2067a4918720Bc04f374c669B313d5" "0x041584444a592d9c9Dbd7D1EDc110D63643408b5" "0x2f70602034854C14CBfD1F94C713f833d344d748")"
verify "0x3AA7E5A28A72Df248806397Ea16C03fB10c46830" "src/curation/CREPublishReceiver.sol:CREPublishReceiver" "$ARGS"

echo ""
echo "Done."
