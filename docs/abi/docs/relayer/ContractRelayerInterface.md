# Contract–Relayer Interface

**Last updated:** 2026-03-01  
**Context:** [CurrentSmartContract.md](../CurrentSmartContract.md) | [RelayerArchitecture.md](RelayerArchitecture.md)

---

## 1. Overview

This document describes the contract methods and data formats the relayer must know to interact with ChannelSettlement and the CRE pipeline.

---

## 2. ChannelSettlement Methods

### 2.1 submitCheckpointFromPayload

```solidity
function submitCheckpointFromPayload(bytes calldata payload) external
```

**Input format:** `payload` = `abi.encode(Checkpoint, Delta[], bytes operatorSig, address[] users, bytes[] userSigs)`

**Call path:** CRE workflow sends `0x03 || payload` → CREReceiver → OracleCoordinator.submitSession → SettlementRouter.finalizeSession → this.

**Preconditions:**
- Payload decodes to bounded arrays (MAX_DELTAS=256, MAX_USERS=256)
- `hash(deltas) == cp.deltasHash`
- Operator signature recovers to `operator`
- Every delta user in `users` with valid signature
- Nonce > latestNonce(marketId, sessionId)

**On success:** Reserves vault balances for debtors; stores pending; emits `CheckpointSubmitted`.

---

### 2.2 finalizeCheckpoint

```solidity
function finalizeCheckpoint(
    uint256 marketId,
    bytes32 sessionId,
    ShadowTypes.Delta[] calldata deltas
) external
```

**Permission:** Anyone (permissionless).

**Inputs:** `marketId`, `sessionId` from checkpoint; `deltas` must match stored `deltasHash` in pending.

**Preconditions:**
- Pending exists for (marketId, sessionId)
- `block.timestamp >= challengeDeadline` (30 min after submit)
- `hash(deltas) == pending.deltasHash`
- Market not resolved; `lastTradeAt <= tradingClose` if tradingClose set

**On success:** Mints/burns OutcomeToken1155; applies cash deltas; LP counterparty; fee routing; releases reserves; deletes pending; emits `CheckpointFinalized`.

**Relayer source for deltas:** `GET /cre/checkpoints/:sessionId` returns `deltas`.

---

### 2.3 challengeCheckpoint

```solidity
function challengeCheckpoint(
    ShadowTypes.Checkpoint calldata newerCp,
    ShadowTypes.Delta[] calldata newerDeltas,
    bytes calldata operatorSig,
    address[] calldata users,
    bytes[] calldata userSigs
) external
```

**Permission:** Anyone.

**Preconditions:**
- Pending exists; within challenge window
- `newerCp.nonce > pending.nonce`
- Same validation as submit (signatures, hash, etc.)

**On success:** Releases old reserves; stores new pending; emits `CheckpointChallenged`.

---

### 2.4 cancelPendingCheckpoint

```solidity
function cancelPendingCheckpoint(uint256 marketId, bytes32 sessionId) external
```

**Permission:** Anyone, after `CANCEL_DELAY` (6 hours) from `createdAt`.

**Purpose:** Escape hatch if relayer never finalizes; releases stuck reserves.

---

### 2.5 latestNonce

```solidity
function latestNonce(uint256 marketId, bytes32 sessionId) external view returns (uint64)
```

Returns the highest finalized nonce for the (marketId, sessionId) key. Relayer must use nonce > this for new checkpoints.

---

### 2.6 digestCheckpoint

```solidity
function digestCheckpoint(ShadowTypes.Checkpoint memory cp) external view returns (bytes32)
```

For test/offchain: returns EIP-712 digest. Relayer typically computes digest off-chain via `getCheckpointDigest`.

---

## 3. Pending State (pendingByKey)

Key: `keccak256(abi.encode(marketId, sessionId))`

| Field | Type | Description |
|-------|------|-------------|
| `nonce` | uint64 | Pending nonce |
| `challengeDeadline` | uint64 | block.timestamp + 30 min at submit |
| `lastTradeAt` | uint48 | From checkpoint |
| `stateHash` | bytes32 | From checkpoint |
| `deltasHash` | bytes32 | Must match finalize deltas |
| `riskHash` | bytes32 | From checkpoint |
| `exists` | bool | True if pending |
| `settlementAsset` | address | Resolved asset |
| `reserveUsers` | address[] | Users with reserved balances |
| `reserveAmts` | uint256[] | Reserved amounts |
| `createdAt` | uint64 | For cancel timeout |

---

## 4. CRE Report Format (0x03)

Report prefix `0x03` routes to session/checkpoint path.

**Full report:** `0x03 || abi.encode(Checkpoint, Delta[], bytes operatorSig, address[] users, bytes[] userSigs)`

**Flow:**
1. CRE workflow fetches payload from relayer `POST /cre/checkpoints/:sessionId`
2. Workflow calls `evmClient.writeReport(0x03 || payload)`
3. Forwarder → CREReceiver.onReport(metadata, report)
4. CREReceiver routes `report[1:]` to OracleCoordinator.submitSession
5. SettlementRouter.finalizeSession decodes and calls ChannelSettlement.submitCheckpointFromPayload

---

## 5. Checkpoint / Delta Structs

See [CheckpointEIP712.md](CheckpointEIP712.md) for full EIP-712 and struct definitions.

**Checkpoint:** marketId, sessionId, nonce, validAfter, validBefore, lastTradeAt, stateHash, deltasHash, riskHash  
**Delta:** user, outcomeIndex, sharesDelta, cashDelta

---

## 6. See Also

- [CheckpointEIP712.md](CheckpointEIP712.md) — EIP-712 spec
- [RelayerAPI.md](RelayerAPI.md) — CRE endpoints
- [CREReportFormats.md](../cre/CREReportFormats.md) — Report type routing
