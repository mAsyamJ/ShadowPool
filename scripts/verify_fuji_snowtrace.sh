#!/usr/bin/env bash
set -euo pipefail

############################################
# RetroPick – Verify All on Avalanche Fuji
# Uses Routescan Etherscan-like verifier (Snowtrace backend)
############################################

ENV_FILE="${ENV_FILE:-.env.fuji}"
WATCH="${WATCH:-1}"          # 1 = wait until verified
DELAY="${DELAY:-0}"          # seconds to sleep before verifying (set e.g. 15 if indexer lag)
CHAIN_ID=43113

# Routescan verifier URL for Fuji testnet
VERIFIER_URL="${VERIFIER_URL:-https://api.routescan.io/v2/network/testnet/evm/${CHAIN_ID}/etherscan}"

# Routescan docs often accept any api-key string; their Foundry guide uses "verifyContract"
ETHERSCAN_API_KEY="${ETHERSCAN_API_KEY:-verifyContract}"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

# Require your ctor-related env vars
: "${MIN_CONFIDENCE:?Missing MIN_CONFIDENCE in ${ENV_FILE}}"
: "${PROTOCOL_FEE_BPS:?Missing PROTOCOL_FEE_BPS in ${ENV_FILE}}"
: "${SETTLEMENT_TOKEN:?Missing SETTLEMENT_TOKEN in ${ENV_FILE}}"
: "${OPERATOR:?Missing OPERATOR in ${ENV_FILE}}"
: "${CHAINLINK_FORWARDER:?Missing CHAINLINK_FORWARDER in ${ENV_FILE}}"

echo "forge build (must match deploy settings)..."
forge build

if [[ "$DELAY" != "0" ]]; then
  echo "Waiting ${DELAY}s for explorer indexer..."
  sleep "$DELAY"
fi

verify() {
  local addr="$1"
  local fq="$2"
  local args="${3:-}"

  echo ""
  echo "============================================================"
  echo "Verifying: $fq"
  echo "Address:   $addr"
  echo "Verifier:  $VERIFIER_URL"
  [[ -n "$args" ]] && echo "CtorArgs:  $args" || echo "CtorArgs:  (none)"
  echo "============================================================"

  local base=(forge verify-contract
    --chain-id "$CHAIN_ID"
    --verifier-url "$VERIFIER_URL"
    --etherscan-api-key "$ETHERSCAN_API_KEY"
  )

  if [[ "$WATCH" == "1" ]]; then
    base+=(--watch)
  fi

  if [[ -n "$args" ]]; then
    "${base[@]}" "$addr" "$fq" --constructor-args "$args"
  else
    "${base[@]}" "$addr" "$fq"
  fi
}

############################################
# Addresses (Fuji)
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
# Verify: NO constructor args
############################################
verify "$ORACLE_COORDINATOR"  "src/oracle/OracleCoordinator.sol:OracleCoordinator"
verify "$SETTLEMENT_ROUTER"   "src/core/SettlementRouter.sol:SettlementRouter"
verify "$FEE_POOL"            "src/fees/FeePool.sol:FeePool"
verify "$TREASURY_POOL"       "src/fees/TreasuryPool.sol:TreasuryPool"
verify "$MARKET_POLICY"       "src/curation/MarketPolicy.sol:MarketPolicy"
verify "$DRAFT_BOARD"         "src/curation/MarketDraftBoard.sol:MarketDraftBoard"

############################################
# Verify: WITH constructor args
############################################

# ReportValidator(uint16)
ARGS=$(cast abi-encode "constructor(uint16)" "$MIN_CONFIDENCE")
verify "$REPORT_VALIDATOR" "src/oracle/ReportValidator.sol:ReportValidator" "$ARGS"

# FeeManager(uint16)
ARGS=$(cast abi-encode "constructor(uint16)" "$PROTOCOL_FEE_BPS")
verify "$FEE_MANAGER" "src/fees/FeeManager.sol:FeeManager" "$ARGS"

# ExecutionLedger(address) -> doc uses address(0)
ARGS=$(cast abi-encode "constructor(address)" "0x0000000000000000000000000000000000000000")
verify "$EXECUTION_LEDGER" "src/execution/ExecutionLedger.sol:ExecutionLedger" "$ARGS"

# MultiAssetVault(address) -> doc uses address(0)
ARGS=$(cast abi-encode "constructor(address)" "0x0000000000000000000000000000000000000000")
verify "$MULTI_ASSET_VAULT" "src/execution/MultiAssetVault.sol:MultiAssetVault" "$ARGS"

# CollateralVault(address,address) -> (SETTLEMENT_TOKEN, address(0))
ARGS=$(cast abi-encode "constructor(address,address)" "$SETTLEMENT_TOKEN" "0x0000000000000000000000000000000000000000")
verify "$COLLATERAL_VAULT" "src/execution/CollateralVault.sol:CollateralVault" "$ARGS"

# ChannelSettlement(address,address,address)
ARGS=$(cast abi-encode "constructor(address,address,address)" \
  "$COLLATERAL_VAULT" \
  "$EXECUTION_LEDGER" \
  "$OPERATOR")
verify "$CHANNEL_SETTLEMENT" "src/execution/ChannelSettlement.sol:ChannelSettlement" "$ARGS"

# MarketRegistry(address,address)
ARGS=$(cast abi-encode "constructor(address,address)" \
  "$COLLATERAL_VAULT" \
  "$EXECUTION_LEDGER")
verify "$MARKET_REGISTRY" "src/core/MarketRegistry.sol:MarketRegistry" "$ARGS"

# CREReceiver(address,address)
ARGS=$(cast abi-encode "constructor(address,address)" \
  "$CHAINLINK_FORWARDER" \
  "$ORACLE_COORDINATOR")
verify "$CRE_RECEIVER" "src/oracle/CREReceiver.sol:CREReceiver" "$ARGS"

# DraftClaimManager(address)
ARGS=$(cast abi-encode "constructor(address)" "$DRAFT_BOARD")
verify "$DRAFT_CLAIM_MANAGER" "src/curation/DraftClaimManager.sol:DraftClaimManager" "$ARGS"

# LiquidityVaultFactory(address)
ARGS=$(cast abi-encode "constructor(address)" "$CHANNEL_SETTLEMENT")
verify "$LIQUIDITY_VAULT_FACTORY" "src/curation/LiquidityVaultFactory.sol:LiquidityVaultFactory" "$ARGS"

# MarketFactory(address,address)
ARGS=$(cast abi-encode "constructor(address,address)" \
  "$CHAINLINK_FORWARDER" \
  "$MARKET_REGISTRY")
verify "$MARKET_FACTORY" "src/core/MarketFactory.sol:MarketFactory" "$ARGS"

# CREPublishReceiver(address,address,address,address,address)
ARGS=$(cast abi-encode "constructor(address,address,address,address,address)" \
  "$CHAINLINK_FORWARDER" \
  "$DRAFT_BOARD" \
  "$DRAFT_CLAIM_MANAGER" \
  "$MARKET_POLICY" \
  "$MARKET_FACTORY")
verify "$CRE_PUBLISH_RECEIVER" "src/curation/CREPublishReceiver.sol:CREPublishReceiver" "$ARGS"

echo ""
echo "Done. If you hit 'contract does not exist', rerun with DELAY=15 or DELAY=30 (indexer lag)."
