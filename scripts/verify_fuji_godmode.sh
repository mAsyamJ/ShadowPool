#!/usr/bin/env bash
set -euo pipefail

############################################
# God-mode verify: Avalanche Fuji (43113)
# Uses Routescan Etherscan-compatible verifier (Snowtrace backend)
#
# Requirements:
#   - forge + cast
#   - jq
#
# Environment options:
#   CHAIN_ID=43113
#   VERIFIER_URL=... (Routescan)
#   ETHERSCAN_API_KEY=verifyContract (placeholder; not real)
#   BROADCAST_FILE=... (optional)
#   PARALLEL=4
#   RETRIES=6
#   SLEEP=8
############################################

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1"; exit 1; }; }
need forge
need cast
need jq
need find
need grep
need sed

CHAIN_ID="${CHAIN_ID:-43113}"
NETWORK_KIND="${NETWORK_KIND:-testnet}" # routescan path: testnet/mainnet
VERIFIER_URL="${VERIFIER_URL:-https://api.routescan.io/v2/network/${NETWORK_KIND}/evm/${CHAIN_ID}/etherscan}"
ETHERSCAN_API_KEY="${ETHERSCAN_API_KEY:-verifyContract}"  # placeholder string (Routescan free tier)
PARALLEL="${PARALLEL:-4}"
RETRIES="${RETRIES:-6}"
SLEEP="${SLEEP:-8}"

# Auto-pick latest broadcast file for this chain unless specified
if [[ -z "${BROADCAST_FILE:-}" ]]; then
  # Prefer chain-specific run-latest.json
  BROADCAST_FILE="$(ls -1t broadcast/**/"${CHAIN_ID}"/run-latest.json 2>/dev/null | head -n 1 || true)"
  if [[ -z "$BROADCAST_FILE" ]]; then
    # Fallback: any run-latest.json (user might have custom folder)
    BROADCAST_FILE="$(ls -1t broadcast/**/run-latest.json 2>/dev/null | head -n 1 || true)"
  fi
fi

if [[ -z "${BROADCAST_FILE:-}" || ! -f "$BROADCAST_FILE" ]]; then
  echo "Could not find Foundry broadcast file."
  echo "Expected something like: broadcast/<Script>.s.sol/${CHAIN_ID}/run-latest.json"
  echo "Set it explicitly: BROADCAST_FILE=path/to/run-latest.json $0"
  exit 1
fi

echo "Using broadcast file: $BROADCAST_FILE"
echo "Verifier URL:         $VERIFIER_URL"
echo "Chain ID:             $CHAIN_ID"
echo "Parallel:             $PARALLEL"
echo ""

echo "Building (must match deploy settings)..."
forge build >/dev/null

# --- Helpers ------------------------------------------------

# Find artifact path for a contract name by searching out/**/<Name>.json
# If ambiguous, we pick the first but print a warning.
artifact_for_contract() {
  local cname="$1"
  local matches
  matches="$(find out -type f -name "${cname}.json" 2>/dev/null || true)"
  if [[ -z "$matches" ]]; then
    echo ""
    return 0
  fi
  local count
  count="$(echo "$matches" | wc -l | tr -d ' ')"
  if [[ "$count" != "1" ]]; then
    echo "WARN: multiple artifacts for ${cname}, picking first:" >&2
    echo "$matches" | sed 's/^/  - /' >&2
  fi
  echo "$matches" | head -n 1
}

# Derive "src/path/File.sol:Contract" from an artifact path:
# out/<File.sol>/<Contract>.json  -> <File.sol path>:<Contract>
# Most Foundry out dirs are like: out/Foo.sol/Bar.json OR out/src/Foo.sol/Bar.json depending config.
fqname_from_artifact() {
  local artifact="$1"
  local cname="$2"

  # artifact dir is out/<something>/<cname>.json
  local dir
  dir="$(dirname "$artifact")"
  # remove leading "out/"
  local rel="${dir#out/}"
  # rel should end with ".sol" (typically)
  echo "${rel}:${cname}"
}

# Extract constructor types (comma-separated) from artifact ABI.
# Returns empty string if no constructor or no inputs.
ctor_types_csv() {
  local artifact="$1"
  jq -r '
    ( .abi // [] )
    | map(select(.type=="constructor"))[0].inputs // []
    | map(.type)
    | join(",")
  ' "$artifact"
}

# Extract constructor values array from broadcast tx object.
# Foundry broadcast usually stores ".arguments" for CREATE.
# Returns JSON array string (e.g. ["0x..", "123"]) or "[]".
ctor_values_json() {
  local tx_json="$1"
  echo "$tx_json" | jq -c '.arguments // .constructorArgs // []'
}

# Encode constructor args using cast abi-encode
# Inputs:
#   types_csv "address,uint16"  (can be empty)
#   values_json ["0x..", "250"]
# Output:
#   0x... (abi-encoded bytes)
encode_ctor_args() {
  local types_csv="$1"
  local values_json="$2"

  if [[ -z "$types_csv" ]]; then
    echo ""
    return 0
  fi

  # Turn JSON array into bash-safe args list
  # We rely on jq to output each element as a raw string.
  mapfile -t vals < <(echo "$values_json" | jq -r '.[] | tostring')

  # If types exist but no values, fail loudly (mismatch)
  if [[ "${#vals[@]}" -eq 0 ]]; then
    echo "ERROR: constructor has types (${types_csv}) but broadcast has no arguments" >&2
    return 2
  fi

  cast abi-encode "constructor(${types_csv})" "${vals[@]}"
}

# Verify a single contract.
# Inputs: address, contractName
verify_one() {
  local addr="$1"
  local cname="$2"
  local tx_json="$3"

  if [[ -z "$addr" || -z "$cname" ]]; then
    return 0
  fi

  local artifact
  artifact="$(artifact_for_contract "$cname")"
  if [[ -z "$artifact" ]]; then
    echo "SKIP: $cname @ $addr (artifact not found in out/**/${cname}.json)"
    return 0
  fi

  local fq
  fq="$(fqname_from_artifact "$artifact" "$cname")"

  local types_csv
  types_csv="$(ctor_types_csv "$artifact")"

  local values_json
  values_json="$(ctor_values_json "$tx_json")"

  local ctor_args=""
  if [[ -n "$types_csv" ]]; then
    ctor_args="$(encode_ctor_args "$types_csv" "$values_json" || true)"
    if [[ -z "$ctor_args" ]]; then
      echo "ERROR: failed to encode constructor args for $cname @ $addr"
      echo "  types:  $types_csv"
      echo "  values: $values_json"
      return 3
    fi
  fi

  echo ""
  echo "============================================================"
  echo "Contract: $cname"
  echo "Address:  $addr"
  echo "FQName:   $fq"
  echo "Artifact: $artifact"
  if [[ -n "$types_csv" ]]; then
    echo "Ctor:     constructor(${types_csv})"
    echo "ArgsHex:  $ctor_args"
  else
    echo "Ctor:     (none)"
  fi
  echo "============================================================"

  local attempt=1
  while [[ "$attempt" -le "$RETRIES" ]]; do
    set +e
    if [[ -n "$ctor_args" ]]; then
      forge verify-contract \
        --chain-id "$CHAIN_ID" \
        --verifier-url "$VERIFIER_URL" \
        --etherscan-api-key "$ETHERSCAN_API_KEY" \
        --watch \
        "$addr" "$fq" \
        --constructor-args "$ctor_args"
    else
      forge verify-contract \
        --chain-id "$CHAIN_ID" \
        --verifier-url "$VERIFIER_URL" \
        --etherscan-api-key "$ETHERSCAN_API_KEY" \
        --watch \
        "$addr" "$fq"
    fi
    local rc=$?
    set -e

    if [[ "$rc" -eq 0 ]]; then
      echo "OK: verified $cname @ $addr"
      return 0
    fi

    echo "WARN: verify failed (attempt ${attempt}/${RETRIES}) for $cname @ $addr"
    echo "      sleeping ${SLEEP}s then retry..."
    sleep "$SLEEP"
    attempt=$((attempt + 1))
  done

  echo "FAIL: could not verify after ${RETRIES} attempts: $cname @ $addr"
  return 1
}

export -f need artifact_for_contract fqname_from_artifact ctor_types_csv ctor_values_json encode_ctor_args verify_one
export CHAIN_ID VERIFIER_URL ETHERSCAN_API_KEY RETRIES SLEEP
export BROADCAST_FILE

# --- Collect CREATE deployments from broadcast ----------------

# We extract CREATE transactions with contractName + contractAddress.
# Different Foundry versions use slightly different keys; we try common ones.
# We keep the full tx JSON to encode args later.
DEPLOYS_JSONL="$(mktemp)"
jq -c '
  .transactions // []
  | map(select(
      (.transactionType? // .type? // "") | ascii_upcase
      | test("CREATE|CREATE2")
    ))
  | map({
      contractName: (.contractName // .contract // .name // ""),
      contractAddress: (.contractAddress // .createdContractAddress // .to // ""),
      tx: .
    })
  | map(select(.contractName != "" and .contractAddress != ""))
  | .[]
' "$BROADCAST_FILE" > "$DEPLOYS_JSONL"

COUNT="$(wc -l < "$DEPLOYS_JSONL" | tr -d ' ')"
if [[ "$COUNT" == "0" ]]; then
  echo "No CREATE deployments found in broadcast file."
  echo "Open it and confirm it contains .transactions[] with contractName/contractAddress."
  echo "Broadcast: $BROADCAST_FILE"
  exit 1
fi

echo "Found ${COUNT} deployed contracts to verify."
echo ""

# --- Run verifications (parallel) -----------------------------

# Format per line: <address>\t<contractName>\t<tx_json>
TASKS="$(mktemp)"
jq -r '[.contractAddress, .contractName, (.tx|tostring)] | @tsv' "$DEPLOYS_JSONL" > "$TASKS"

run_task() {
  local addr="$1"
  local cname="$2"
  local tx_str="$3"
  verify_one "$addr" "$cname" "$tx_str"
}
export -f run_task

# Use xargs parallelism safely with tab-delimited fields
# shellcheck disable=SC2016
cat "$TASKS" | xargs -P "$PARALLEL" -n 1 -I{} bash -lc '
  IFS=$'\''\t'\'' read -r addr cname tx <<< "{}"
  run_task "$addr" "$cname" "$tx"
'

echo ""
echo "All verification tasks submitted/completed."
echo "If anything was SKIP or FAIL, the usual causes:"
echo "  - artifact not found in out/**/<Contract>.json"
echo "  - deploy used different optimizer/viaIR/solc than current build"
echo "  - broadcast JSON missing constructor arguments"
