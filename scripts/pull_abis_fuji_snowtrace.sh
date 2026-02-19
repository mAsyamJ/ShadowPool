#!/usr/bin/env bash

# DO NOT EXIT ON ERROR
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

OUT_DIR=".docs/abi"
mkdir -p "$OUT_DIR"

API_BASE="https://api-testnet.snowtrace.io/api"

API_KEY="${ETHERSCAN_API_KEY:-${SNOWTRACE_API_KEY:-}}"

echo "Snowtrace API: $API_BASE"
echo "Output dir:    $OUT_DIR"
echo

need() {
 command -v "$1" >/dev/null || {
   echo "Missing dependency: $1"
   exit 1
 }
}

need curl
need jq

# -----------------------------
# Contracts
# -----------------------------

CONTRACTS=(
"ExecutionLedger|0xE4d4187d6Ca2c4eA36A05d3eb61a7A79da7F6D25"
"CollateralVault|0xe1557c8f239752A22278a5c55f0CB28b041D9fcd"
"MultiAssetVault|0xf780caB68DE9800fd6b8ee6AEfc0b06A5F3181dB"
"ChannelSettlement|0xa1F7673D2677FB9e48C7a6295DD7cF44F8c0A212"
"SettlementRouter|0x789daEE98ac0C8EEe220Dd768f0e2A05C66B983E"
"MarketRegistry|0xdB8d890B9aE6A40D2838A508F7D2126cb42a36E4"
"FeeManager|0xB9C04B35C64dc263809DaeA3233de0855b44a82D"
"FeePool|0x59d2B7563bC7b80c3EcE9A3E616441e68ca158A6"
"TreasuryPool|0x1723701b8143537e023b9C6165dAeF9A67125d43"
"ReportValidator|0xC6c31b73CE71B42aB45dd017061fcd5D9620a1bE"
"OracleCoordinator|0xA30Fa013c5CAe93C2e75129ceA669635e011d6F8"
"CREReceiver|0xf427BC9e8C7004F394fa06147bf42aad1D516FdF"
"MarketPolicy|0x98f399081CbDB2eeB66c8c3c51F5fF592A045396"
"MarketDraftBoard|0xa1A31B61748252D7E1f15B2F74de0ce99f1a296f"
"DraftClaimManager|0x1Ccccc54e0cE928b3FC04aA2Ed4E012E7EaAdDe9"
"LiquidityVaultFactory|0xd895dD8547A0fC6214A7ce9D74B49F9b0601C362"
"MarketFactory|0x68D0e961FdFAF031323099a4680847321eFBb7e5"
"CREPublishReceiver|0xEF0aebe656c82A6d070f904c0c31EE1B0B81fBB2"
)

OK=0
FAIL=0
SKIP=0

fetch_abi () {

 local name="$1"
 local addr="$2"

 url="$API_BASE?module=contract&action=getabi&address=$addr"

 [[ -n "$API_KEY" ]] && url="$url&apikey=$API_KEY"

 tmp=$(mktemp)

 if ! curl -sS "$url" -o "$tmp"; then
   echo "  ERROR curl failed"
   ((FAIL++))
   rm -f "$tmp"
   return
 fi

 status=$(jq -r '.status // ""' "$tmp" 2>/dev/null)

 if [[ "$status" != "1" ]]; then
   msg=$(jq -r '.result // ""' "$tmp")
   echo "  SKIP: $msg"
   ((SKIP++))
   rm -f "$tmp"
   return
 fi

 abi=$(jq -r '.result' "$tmp")

 out="$OUT_DIR/$name.json"

 if ! printf '%s' "$abi" | jq '.' > "$out"; then
   echo "  ERROR ABI parse"
   ((FAIL++))
   rm -f "$tmp"
   return
 fi

 echo "  OK → $out"

 rm -f "$tmp"

 ((OK++))
}

# -----------------------------
# LOOP
# -----------------------------

for entry in "${CONTRACTS[@]}"; do

 IFS="|" read -r name addr <<< "$entry"

 echo "Fetching ABI: $name"

 fetch_abi "$name" "$addr"

 # Snowtrace free tier limit
 sleep 1

done

echo
echo "========== RESULT =========="
echo "OK    : $OK"
echo "SKIP  : $SKIP"
echo "FAIL  : $FAIL"
echo "============================"
