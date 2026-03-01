# Checkpoint EIP-712 Specification

**Last updated:** 2026-03-01  
**Context:** [RelayerArchitecture.md](RelayerArchitecture.md) | [CurrentSmartContract.md](../CurrentSmartContract.md)  
**Source:** [ShadowEIP712.sol](../../../src/libs/ShadowEIP712.sol), [ShadowTypes.sol](../../../src/libs/ShadowTypes.sol), [buildCheckpointPayload.ts](../../../../../apps/relayer/src/settlement/buildCheckpointPayload.ts)

---

## 1. Overview

RetroPick checkpoints use **EIP-712 typed data signing**. The digest is computed off-chain (relayer) and on-chain (ChannelSettlement) identically. Both **operator** and **every delta user** must sign the checkpoint digest.

---

## 2. EIP-712 Domain

| Field | Value |
|-------|-------|
| `name` | `ShadowPool` |
| `version` | `1` |
| `chainId` | Deployment chain ID |
| `verifyingContract` | ChannelSettlement contract address |

---

## 3. Type Strings

### 3.1 Checkpoint

```
Checkpoint(uint256 marketId,bytes32 sessionId,uint64 nonce,uint64 validAfter,uint64 validBefore,uint48 lastTradeAt,bytes32 stateHash,bytes32 deltasHash,bytes32 riskHash)
```

**Type hash (keccak256 of above):** Used in struct hashing.

### 3.2 Delta

```
Delta(address user,uint32 outcomeIndex,int128 sharesDelta,int128 cashDelta)
```

**Type hash (keccak256 of above):** Used for `deltasHash` computation.

---

## 4. Struct Definitions

### 4.1 Checkpoint (ShadowTypes.Checkpoint)

| Field | Type | Description |
|-------|------|-------------|
| `marketId` | uint256 | Target market |
| `sessionId` | bytes32 | Session identifier |
| `nonce` | uint64 | Strictly increasing; replay protection |
| `validAfter` | uint64 | Optional validity start (0 = no lower bound) |
| `validBefore` | uint64 | Optional validity end (0 = no upper bound) |
| `lastTradeAt` | uint48 | Must be ≤ market.tradingClose when finalizing |
| `stateHash` | bytes32 | Off-chain state commitment |
| `deltasHash` | bytes32 | keccak256 of Delta[] (see §5) |
| `riskHash` | bytes32 | Optional risk data (often zero) |

### 4.2 Delta (ShadowTypes.Delta)

| Field | Type | Description |
|-------|------|-------------|
| `user` | address | Affected user |
| `outcomeIndex` | uint32 | Outcome (0 = Yes for binary) |
| `sharesDelta` | int128 | Change in OutcomeToken1155 position |
| `cashDelta` | int128 | Change in vault balance (negative = spend) |

---

## 5. Delta Hashing (deltasHash)

`deltasHash` = `keccak256(concat(hash(Delta_0), hash(Delta_1), ...))`

Each `hash(Delta)` = `keccak256(encode(DELTA_TYPEHASH, user, outcomeIndex, sharesDelta, cashDelta))`

**Solidity:** `ShadowEIP712._hashDeltas(deltas)`  
**TypeScript:** `hashDeltas(deltas)` in buildCheckpointPayload.ts

---

## 6. Digest Computation

**EIP-712 digest** = `keccak256("\x19\x01" || domainSeparator || structHash)`

- `domainSeparator` = `keccak256(encode(EIP712Domain, name, version, chainId, verifyingContract))`
- `structHash` = `keccak256(encode(CHECKPOINT_TYPEHASH, marketId, sessionId, nonce, validAfter, validBefore, lastTradeAt, stateHash, deltasHash, riskHash))`

**Solidity:** `ShadowEIP712._digestCheckpoint(cp)` → `_hashTypedDataV4(_hashCheckpoint(cp))`  
**TypeScript:** `getCheckpointDigest(cp, chainId, verifyingContract)` in buildCheckpointPayload.ts

---

## 7. Signers

| Signer | Requirement |
|--------|--------------|
| **Operator** | Must recover to `ChannelSettlement.operator` |
| **Users** | Every unique `delta.user` must appear in `users[]` with valid signature over digest |

`users.length == userSigs.length`; no duplicate users.

---

## 8. Payload Encoding (CRE Report 0x03)

Full payload:

```
0x03 || abi.encode(Checkpoint, Delta[], bytes operatorSig, address[] users, bytes[] userSigs)
```

- `users` must match the set of `delta.user`; order aligns with `userSigs`
- `deltasHash` in Checkpoint must equal `keccak256` of the Delta array

---

## 9. sessionStateToDeltas Algorithm

From [buildCheckpointPayload.ts](../../../../../apps/relayer/src/settlement/buildCheckpointPayload.ts):

For each account in session state:

1. **Cash delta:** `cashDelta = initialBalance - balance`
2. **Position deltas:** For each outcome with non-zero shares, emit `Delta{ user, outcomeIndex, sharesDelta: position, cashDelta }`; only the **first** outcome gets the cash delta
3. **Cash-only users:** One Delta with `outcomeIndex=0`, `sharesDelta=0`, `cashDelta`

---

## 10. On-Chain Guarantees

`ChannelSettlement` enforces:

- **Bounded payload:** `MAX_DELTAS=256`, `MAX_USERS=256`
- **Hash match:** `hash(deltas) == cp.deltasHash`
- **Validity window:** `validAfter`, `validBefore`
- **Operator signature:** Must recover to configured `operator`
- **User signatures:** Every delta user must sign; no duplicates
- **Nonce monotonicity:** Nonce strictly increasing over finalized nonce
- **Challenge window:** 30 minutes; finalize only after window
- **Market close:** `lastTradeAt <= tradingClose` when `tradingClose != 0`

---

## 11. References

- [ShadowEIP712.sol](../../../src/libs/ShadowEIP712.sol) — EIP-712 hashing
- [ShadowTypes.sol](../../../src/libs/ShadowTypes.sol) — Struct definitions
- [buildCheckpointPayload.ts](../../../../../apps/relayer/src/settlement/buildCheckpointPayload.ts) — Offchain payload construction
- [ChannelSettlement.sol](../../../src/execution/ChannelSettlement.sol) — Onchain verification
