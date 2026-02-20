# Nitrolite Yellow Checkpoint Format

**Last updated:** 2026-02-20  
**Context:** [RelayerOverview.md](RelayerOverview.md) | [CREReportFormats.md](../cre/CREReportFormats.md)  
**Source:** [buildCheckpointPayload.ts](../../../../../../apps/relayer/src/settlement/buildCheckpointPayload.ts)

---

## 1. Why Deltas (Not Snapshot)?

Nitrolite Yellow uses **incremental deltas** rather than full balance snapshots:

| Approach | Payload | Pros | Cons |
|----------|---------|------|------|
| **Deltas** (Nitrolite) | `Delta[]` per user: share + cash changes | Compact; verifiable via hashes; replay-safe with nonce | Requires `ExecutionLedger` to apply incrementally |
| **Snapshot** (Legacy) | `participants[]`, `balances[]`, sigs | Simple to decode | Large; repeats full state; less gas-efficient |

The ExecutionLedger already stores per-(user, market, outcome) positions. Checkpoints apply **deltas** to the ledger and vault; no need to overwrite with a full snapshot. Nonce monotonicity prevents replay.

---

## 2. Checkpoint Struct (ShadowTypes.Checkpoint)

| Field | Type | Description |
|-------|------|-------------|
| `marketId` | uint256 | Target market |
| `sessionId` | bytes32 | Session identifier |
| `nonce` | uint64 | Strictly increasing; replay protection |
| `validAfter` | uint64 | Optional validity start |
| `validBefore` | uint64 | Optional validity end |
| `lastTradeAt` | uint48 | Must be ≤ market.tradingClose when finalizing |
| `stateHash` | bytes32 | Off-chain state commitment |
| `deltasHash` | bytes32 | keccak256 of Delta[]; must match payload |
| `riskHash` | bytes32 | Optional risk data |

---

## 3. Delta Struct (ShadowTypes.Delta)

| Field | Type | Description |
|-------|------|-------------|
| `user` | address | Affected user |
| `outcomeIndex` | uint32 | Outcome (0 = Yes for binary) |
| `sharesDelta` | int128 | Change in ExecutionLedger position |
| `cashDelta` | int128 | Change in vault balance (negative = spend) |

### 3.1 sessionStateToDeltas Algorithm

From [buildCheckpointPayload.ts](../../../../../../apps/relayer/src/settlement/buildCheckpointPayload.ts):

For each account in session state:

1. **Cash delta**: `cashDelta = initialBalance - balance` (positive = user received; negative = user spent).
2. **Position deltas**: For each outcome with non-zero shares, emit `Delta{ user, outcomeIndex, sharesDelta: position, cashDelta }`; only the **first** outcome gets the cash delta (to avoid double-counting).
3. **Cash-only users** (no positions): One Delta with `outcomeIndex=0`, `sharesDelta=0`, `cashDelta=initialBalance-balance`.

Result: One Delta per `(user, outcome)` with non-zero shares; users with only cash changes get one Delta.

---

## 4. EIP-712 Signing

**Domain:**
- name: `ShadowPool`
- version: `1`
- chainId: deployment chain
- verifyingContract: `ChannelSettlement` address

**Primary type:** `Checkpoint`

**Type string:**
```
Checkpoint(uint256 marketId,bytes32 sessionId,uint64 nonce,uint64 validAfter,uint64 validBefore,uint48 lastTradeAt,bytes32 stateHash,bytes32 deltasHash,bytes32 riskHash)
```

Both **operator** and **every delta user** must sign the checkpoint digest.

---

## 5. Payload Encoding

Full payload for CRE (prefix `0x03`):

```
0x03 || abi.encode(Checkpoint, Delta[], bytes operatorSig, address[] users, bytes[] userSigs)
```

- `users` must match the set of `delta.user`; order must align with `userSigs`.
- `deltasHash` in Checkpoint must equal `keccak256` of the Delta array (relayer computes this).

---

## 6. On-Chain Guarantees

`ChannelSettlement` enforces:

- **Bounded payload:** `MAX_DELTAS=256`, `MAX_USERS=256`
- **Hash match:** `hash(deltas) == cp.deltasHash`
- **Validity window:** `validAfter`, `validBefore`
- **Operator signature:** Must recover to configured `operator`
- **User signatures:** Every delta user must sign; `users.length == userSigs.length`; no duplicates
- **Nonce monotonicity:** Nonce strictly increasing over finalized nonce
- **Challenge window:** 30 minutes (`CHALLENGE_WINDOW_SECONDS`); finalize only after window
- **Market close:** `lastTradeAt <= tradingClose` when `tradingClose != 0`

---

## 7. Nitrolite vs RetroPick Checkpoint

Nitrolite's protocol includes **checkpointing** — recording valid states on-chain without closing the channel. RetroPick's `ChannelSettlement` implements a **custom** checkpoint format tailored for prediction markets:

- **State commitment**: `stateHash` = hash of session state; `deltasHash` = hash of Delta[].
- **Deltas**: RetroPick deltas map directly to `ExecutionLedger` and vault operations.
- **Domain**: `ShadowPool` v1, verifying contract = ChannelSettlement (not Nitrolite's ChannelEngine).

The relayer uses Nitrolite for **custody/adjudicator** and **state signing** (WalletStateSigner); checkpoint encoding and on-chain handling are RetroPick-specific.

---

## 8. References

- [buildCheckpointPayload.ts](../../../../../../apps/relayer/src/settlement/buildCheckpointPayload.ts)
- [ChannelSettlement.sol](../../../src/execution/ChannelSettlement.sol)
