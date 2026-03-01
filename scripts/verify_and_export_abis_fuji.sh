#!/usr/bin/env bash
set -euo pipefail

############################################
# RetroPick – Verify DeployBetaTestnet on Snowtrace + Export ABIs
# 1. Verifies all 24 contracts on Avalanche Fuji (43113) via verify_beta_fuji.sh
# 2. Exports ABIs from forge build artifacts to docs/abi/
#
# Prerequisites: forge, cast, jq; source scripts/env/.env.fuji
############################################

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

ENV_FILE="${ENV_FILE:-scripts/env/.env.fuji}"
SKIP_VERIFY="${SKIP_VERIFY:-0}"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

# All 24 DeployBetaTestnet contracts (from README)
CONTRACTS=(
  MockUSDC MockDAI MockUSDT MockEURC MockAVAX MockIDRX
  Faucet OutcomeToken1155 MarketRiskManager ChannelSettlement
  MultiAssetVault CollateralVault MarketRegistry FeeManager FeePool TreasuryPool
  ReportValidator CREReceiver OracleCoordinator SettlementRouter
  MarketPolicy MarketDraftBoard DraftClaimManager LiquidityVaultFactory
  CREPublishReceiver MarketFactory
)

OUT_DIR="$ROOT/docs/abi"
mkdir -p "$OUT_DIR"

############################################
# Step 1: Verification
############################################

if [[ "$SKIP_VERIFY" == "1" ]]; then
  echo "SKIP_VERIFY=1 — skipping verification, building only."
else
  echo "===== Step 1: Verify all contracts on Snowtrace (Fuji 43113) ====="
  "$ROOT/scripts/verify_beta_fuji.sh" || {
    echo "WARN: Some verifications failed. Continuing with ABI export."
  }
fi

############################################
# Step 2: ABI Export
############################################

echo ""
echo "===== Step 2: Export ABIs from out/ to $OUT_DIR ====="

need() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1"; exit 1; }
}
need forge
need jq

forge build -q

OK=0
FAIL=0

for name in "${CONTRACTS[@]}"; do
  # Exclude test artifacts (e.g. *.t.sol, test/)
  artifact="$(find out -type f -name "${name}.json" 2>/dev/null | grep -v '\.t\.sol' | head -n 1)"
  [[ -z "$artifact" ]] && artifact="$(find out -type f -name "${name}.json" 2>/dev/null | head -n 1)"

  if [[ -z "$artifact" ]] || [[ ! -f "$artifact" ]]; then
    echo "  FAIL: $name — artifact not found in out/"
    FAIL=$((FAIL + 1))
    continue
  fi

  out="$OUT_DIR/$name.json"
  if jq -e '.abi' "$artifact" >/dev/null 2>&1; then
    jq '.abi' "$artifact" > "$out"
    echo "  OK → $out"
    OK=$((OK + 1))
  else
    echo "  FAIL: $name — no .abi in $artifact"
    FAIL=$((FAIL + 1))
  fi
done

echo ""
echo "========== ABI Export Result =========="
echo "OK   : $OK"
echo "FAIL : $FAIL"
echo "======================================="

if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
