# CRE Report Formats

**Last updated:** 2026-02-20  
**Context:** [CREOverview.md](CREOverview.md) | [CurrentSmartContract.md](../CurrentSmartContract.md)

---

## 1. CREReceiver Reports

### 1.1 Outcome Report (Default, No Prefix)

Used for market resolution. `report[0] != 0x03` triggers this path.

**Encoding:**
```
abi.encode(address market, uint256 marketId, uint8 outcomeIndex, uint16 confidence)
```

| Field | Type | Description |
|-------|------|-------------|
| `market` | address | Market receiver (e.g. `MarketRegistry`) |
| `marketId` | uint256 | Market ID |
| `outcomeIndex` | uint8 | Winning outcome (0 = Yes for binary) |
| `confidence` | uint16 | Oracle confidence (basis-point-like; e.g. 9000 = 90%) |

**Flow:** `CREReceiver` → `OracleCoordinator.submitResult` → `ReportValidator.validate` → `SettlementRouter.settleMarket` → `MarketRegistry.onReport(0x01 || abi.encode(...))`

---

### 1.2 Session Report (Nitrolite Yellow Checkpoint) — Prefix `0x03`

Used for checkpoint settlement. `report.length > 0 && report[0] == 0x03` triggers this path. Payload is `report[1:]`.

**Encoding:**
```
0x03 || abi.encode(Checkpoint, Delta[], bytes operatorSig, address[] users, bytes[] userSigs)
```

**Checkpoint struct (ShadowTypes.Checkpoint):**

| Field | Type | Description |
|-------|------|-------------|
| `marketId` | uint256 | Target market |
| `sessionId` | bytes32 | Session identifier |
| `nonce` | uint64 | Strictly increasing; replay protection |
| `validAfter` | uint64 | Optional validity start |
| `validBefore` | uint64 | Optional validity end |
| `lastTradeAt` | uint48 | Must be ≤ market.tradingClose |
| `stateHash` | bytes32 | Off-chain state commitment |
| `deltasHash` | bytes32 | keccak256 of Delta[] (must match payload) |
| `riskHash` | bytes32 | Optional risk data |

**Delta struct (ShadowTypes.Delta):**

| Field | Type | Description |
|-------|------|-------------|
| `user` | address | Affected user |
| `outcomeIndex` | uint32 | Outcome (0 = Yes for binary) |
| `sharesDelta` | int128 | Change in ExecutionLedger position |
| `cashDelta` | int128 | Change in vault balance (negative = spend) |

**Flow:** `CREReceiver` → `OracleCoordinator.submitSession` → `SettlementRouter.finalizeSession` → `ChannelSettlement.submitCheckpointFromPayload`

---

## 2. CREPublishReceiver Reports — Prefix `0x04`

`CREPublishReceiver` is a separate receiver; Forwarder routes publish reports to it (not CREReceiver).

**Encoding:**
```
[0x04?] abi.encode(bytes32 draftId, address creator, DraftPublishParams params, bytes claimerSig)
```

Payload: `report[1:]` when `report[0] == 0x04`, else full `report`.

**DraftPublishParams:**
```solidity
struct DraftPublishParams {
    string question;
    uint8 marketType;
    string[] outcomes;
    uint48[] timelineWindows;
    uint48 resolveTime;
    uint48 tradingOpen;
    uint48 tradingClose;
}
```

**Flow:** `CREPublishReceiver.onReport` → verifies EIP-712 `PublishFromDraft` signature → `MarketFactory.createFromDraft`

---

## 3. Report Routing Summary

| Receiver | Prefix | Payload | Action |
|----------|--------|---------|--------|
| CREReceiver | `0x03` | Session payload | ChannelSettlement (Nitrolite Yellow) |
| CREReceiver | (default) | Outcome | MarketRegistry / PoolMarketLegacy |
| CREPublishReceiver | `0x04` (optional) | Publish params + sig | MarketFactory.createFromDraft |

---

## 4. References

- [CREReceiver.sol](../../../src/oracle/CREReceiver.sol) — lines 31–41
- [CREPublishReceiver.sol](../../../src/curation/CREPublishReceiver.sol) — lines 68–76
- [SettlementRouter.sol](../../../src/core/SettlementRouter.sol) — `finalizeSession` payload decode
