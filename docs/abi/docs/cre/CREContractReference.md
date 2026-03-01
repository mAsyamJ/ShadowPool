# CRE Contract Reference

**Last updated:** 2026-03-01  
**Context:** [CREOverview.md](CREOverview.md) | [CurrentSmartContract.md](../CurrentSmartContract.md)

---

## 1. Overview

This document describes the contract methods, guards, and routing logic for the CRE integration pipeline. All receivers extend [ReceiverTemplate.sol](../../src/interfaces/ReceiverTemplate.sol).

---

## 2. ReceiverTemplate

**Path:** [src/interfaces/ReceiverTemplate.sol](../../src/interfaces/ReceiverTemplate.sol)

### 2.1 Forwarder Check

- **Guard:** `msg.sender == sForwarderAddress` (when configured; address(0) disables)
- **Error:** `InvalidSender(sender, expected)` if caller is not Forwarder
- **Purpose:** Only the Chainlink Forwarder can call `onReport`

### 2.2 Optional Workflow Metadata Validation

When any of these are set, `onReport` validates metadata before calling `_processReport`:

| Setter | Field | Purpose |
|--------|-------|---------|
| `setExpectedWorkflowId(bytes32)` | `sExpectedWorkflowId` | Only reports from this workflow ID |
| `setExpectedAuthor(address)` | `sExpectedAuthor` | Only reports from this workflow owner |
| `setExpectedWorkflowName(string)` | `sExpectedWorkflowName` | Only reports from this workflow name |

**Constraint:** Workflow name validation **requires** author validation (collision risk with bytes10 truncation).

### 2.3 _decodeMetadata

Metadata structure (from Forwarder `abi.encodePacked`):

- Offset 32, size 32: `workflowId` (bytes32)
- Offset 64, size 10: `workflowName` (bytes10)
- Offset 74, size 20: `workflowOwner` (address)

### 2.4 Abstract _processReport

Implementations override `_processReport(bytes calldata report)` with routing logic.

---

## 3. CREReceiver

**Path:** [src/oracle/CREReceiver.sol](../../src/oracle/CREReceiver.sol)

### 3.1 Constructor

```solidity
constructor(address forwarderAddress, address coordinator)
```

- `forwarderAddress` — Chainlink Forwarder (required)
- `coordinator` — OracleCoordinator address

### 3.2 _processReport (lines 31–41)

**Routing logic:**

```solidity
if (report.length > 0 && report[0] == 0x03) {
    oracleCoordinator.submitSession(report[1:]);
    return;
}
(address market, uint256 marketId, uint8 outcomeIndex, uint16 confidence) =
    abi.decode(report, (address, uint256, uint8, uint16));
oracleCoordinator.submitResult(market, marketId, outcomeIndex, confidence);
```

| Condition | Action |
|-----------|--------|
| `report[0] == 0x03` | Session path: `submitSession(report[1:])` |
| Else | Outcome path: decode and `submitResult` |

---

## 4. OracleCoordinator

**Path:** [src/oracle/OracleCoordinator.sol](../../src/oracle/OracleCoordinator.sol)

### 4.1 Guards

- **submitResult** — `onlyReceiver` (msg.sender == creReceiver)
- **submitSession** — `onlyReceiver`

### 4.2 submitResult

```solidity
function submitResult(address market, uint256 marketId, uint8 outcomeIndex, uint16 confidence) external onlyReceiver
```

- If `reportValidator != 0`: calls `reportValidator.validate(confidence)`; reverts `InvalidConfidence` on failure
- Forwards to `SettlementRouter.settleMarket(market, marketId, outcomeIndex, confidence)`

### 4.3 submitSession

```solidity
function submitSession(bytes calldata payload) external onlyReceiver
```

- Forwards to `SettlementRouter.finalizeSession(payload)`

---

## 5. SettlementRouter

**Path:** [src/core/SettlementRouter.sol](../../src/core/SettlementRouter.sol)

### 5.1 Guards

- **settleMarket** — `onlyOracleCoordinator`
- **finalizeSession** — `onlyOracleCoordinator`

### 5.2 settleMarket

Builds internal report: `0x01 || abi.encode(marketId, outcomeIndex, confidence)`.

Forwards to `market.onReport("", report)`. Market must implement `IPredictionMarketReceiver`.

- If `useReceiverAllowlist`: `market` must be in `approvedMarketReceivers`; else `Unauthorized`

### 5.3 finalizeSession (lines 111–143)

**Routing:**

| Condition | Action |
|-----------|--------|
| `channelSettlement != 0` | Decode checkpoint; call `ChannelSettlement.submitCheckpointFromPayload(payload)`; emit `SessionPayloadRouted(..., routeType=1)` |
| `sessionFinalizer != 0` | Call `SessionFinalizer.finalizeSession(payload)`; emit `SessionPayloadRouted(..., routeType=0)` |
| Else | Revert `InvalidAddress` |

Checkpoint payload format: `abi.encode(Checkpoint, Delta[], bytes operatorSig, address[] users, bytes[] userSigs)`.

---

## 6. CREPublishReceiver

**Path:** [src/curation/CREPublishReceiver.sol](../../src/curation/CREPublishReceiver.sol)

### 6.1 Constructor

```solidity
constructor(
    address forwarderAddress,
    address draftBoard_,
    address draftClaimManager_,
    address marketPolicy_,
    address marketFactory_
)
```

### 6.2 _processReport (lines 68–111)

**Payload:** `report[1:]` when `report[0] == 0x04`, else full `report`.

**Decode:** `(draftId, creator, DraftPublishParams, claimerSig)`

**Validation:**

1. `DRAFT_BOARD.getStatus(draftId) == Claimed` — else `DraftNotClaimed`
2. `DRAFT_CLAIM_MANAGER.getClaimer(draftId) == creator` — else `InvalidCreator`
3. EIP-712 `PublishFromDraft` signature recovers to `creator` — else `InvalidSignature`

**EIP-712:** Domain `CREPublishReceiver` v1; type `PublishFromDraft(bytes32 draftId, bytes32 paramsHash, uint256 chainId, uint256 nonce)`.

**Action:** `MARKET_FACTORY.createFromDraft(draftId, creator, params)`

---

## 7. Access Chain Summary

| Caller | Callee | Guard |
|--------|--------|-------|
| Chainlink Forwarder | CREReceiver / CREPublishReceiver | Forwarder address check |
| CREReceiver | OracleCoordinator | — |
| OracleCoordinator | SettlementRouter | onlyReceiver |
| SettlementRouter | ChannelSettlement / MarketRegistry / SessionFinalizer | onlyOracleCoordinator |
| MarketRegistry | onReport | msg.sender == settlementRouter |

---

## 8. References

- [CREPipelineDiagram.md](CREPipelineDiagram.md) — Full flow diagrams
- [CREReportFormats.md](CREReportFormats.md) — Payload schemas
- [CurrentSmartContract.md](../CurrentSmartContract.md) §6, §14.5 — Flows and checkpoint guarantees
