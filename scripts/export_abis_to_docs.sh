#!/usr/bin/env bash
set -euo pipefail

############################################
# RetroPick – Export DeployBetaTestnet ABIs to docs/abi/
# Extracts ABIs from forge build artifacts (out/) without verification.
# Useful for CI, rebuilds, or when verification is already done.
############################################

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

# All DeployBetaTestnet contracts (from README)
CONTRACTS=(
  MockUSDC MockDAI MockUSDT MockEURC MockAVAX MockIDRX
  Faucet OutcomeToken1155 MarketRiskManager ChannelSettlement
  MultiAssetVault CollateralVault MarketRegistry FeeManager FeePool TreasuryPool
  ReportValidator CREReceiver OracleCoordinator SettlementRouter
  MarketPolicy MarketDraftBoard DraftClaimManager LiquidityVaultFactory
  CREPublishReceiver MarketFactory
)

OUT_DIR="${OUT_DIR:-$ROOT/docs/abi}"
mkdir -p "$OUT_DIR"

need() {
  command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1"; exit 1; }
}
need forge
need jq

echo "Exporting ABIs from out/ to $OUT_DIR"
forge build -q

OK=0
FAIL=0

for name in "${CONTRACTS[@]}"; do
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
echo "========== Result =========="
echo "OK   : $OK"
echo "FAIL : $FAIL"
echo "============================"

if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
