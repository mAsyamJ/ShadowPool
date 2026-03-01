# CRE Workflow: Outcome Resolution

**Last updated:** 2026-03-01  
**Context:** [CREOverview.md](CREOverview.md) | [CREPipelineDiagram.md](CREPipelineDiagram.md)

---

## 1. Overview

The outcome workflow delivers market resolution data (winning outcome, confidence) to the settlement router. The CRE workflow fetches outcome data from an oracle source, encodes it, and sends it via `writeReport` to CREReceiver. No relayer involved.

---

## 2. Trigger Options

| Trigger | Use case |
|---------|----------|
| **Cron** | Periodic resolution check (e.g. after market close) |
| **HTTP** | External service triggers when resolution is ready |
| **EVM log** | React to off-chain resolution event |

---

## 3. Payload Encoding

**No prefix.** Outcome reports use the default CREReceiver path.

```
abi.encode(address market, uint256 marketId, uint8 outcomeIndex, uint16 confidence)
```

| Field | Type | Description |
|-------|------|-------------|
| `market` | address | Market receiver (e.g. `MarketRegistry` or `PoolMarketLegacy`) |
| `marketId` | uint256 | Market ID |
| `outcomeIndex` | uint8 | Winning outcome (0 = Yes for binary) |
| `confidence` | uint16 | Oracle confidence (e.g. 9000 = 90%) |

---

## 4. Flow

1. **Fetch outcome data** — From oracle API, data feed, or internal logic
2. **Encode payload** — `abi.encode(market, marketId, outcomeIndex, confidence)`
3. **Submit** — `evmClient.writeReport(payload)` (no `0x03` prefix)
4. **On-chain** — CREReceiver → OracleCoordinator.submitResult → ReportValidator (if set) → SettlementRouter.settleMarket
5. **SettlementRouter** builds `0x01 || abi.encode(marketId, outcomeIndex, confidence)` and calls `market.onReport("", report)`
6. **MarketRegistry** (or PoolMarketLegacy) decodes and resolves

---

## 5. ReportValidator Hook

If `OracleCoordinator.reportValidator` is set, `validate(confidence)` is called before `settleMarket`. Low confidence causes `InvalidConfidence` revert. Configure `ReportValidator.minConfidence` per policy.

---

## 6. Configuration

| Variable | Description |
|----------|-------------|
| Oracle data source | API URL or feed for resolution data |
| `market` | Address of MarketRegistry or PoolMarketLegacy |
| Receiver | Workflow must target **CREReceiver** |
| ReportValidator | Optional; enforce min confidence |

---

## 7. Market Allowlist

If `SettlementRouter.useReceiverAllowlist` is true, `market` must be in `approvedMarketReceivers`. Otherwise `settleMarket` reverts `Unauthorized`.

---

## 8. References

- [CREPipelineDiagram.md](CREPipelineDiagram.md) — Outcome sequence diagram
- [CREReportFormats.md](CREReportFormats.md) — Outcome payload schema
- [CurrentSmartContract.md](../CurrentSmartContract.md) §6.1 — Oracle outcome flow
