# Integration Matrix

**Last updated:** 2026-02-20  
**Context:** [CurrentSmartContract.md](CurrentSmartContract.md) | [CREOverview.md](cre/CREOverview.md)

---

## 1. Contract → Report Type → CRE Path

| Receiver | Report Prefix | Report Type | On-Chain Target | Action |
|----------|---------------|-------------|-----------------|--------|
| CREReceiver | `0x03` | Session (Nitrolite Yellow) | ChannelSettlement | `submitCheckpointFromPayload` |
| CREReceiver | (default) | Outcome | MarketRegistry / PoolMarketLegacy | `onReport(0x01...)` / resolve |
| CREPublishReceiver | `0x04` (optional) | Publish from draft | MarketFactory | `createFromDraft` |

---

## 2. Ingress Chain

| Step | Caller | Callee | Guard |
|------|--------|--------|-------|
| 1 | Chainlink Forwarder | CREReceiver / CREPublishReceiver | Forwarder only |
| 2 | CREReceiver | OracleCoordinator | onlyReceiver |
| 3 | OracleCoordinator | SettlementRouter | — |
| 4a | SettlementRouter | ChannelSettlement | (session path) |
| 4b | SettlementRouter | MarketRegistry | settleMarket → onReport |
| (Publish) | Forwarder | CREPublishReceiver | Forwarder only |
| (Publish) | CREPublishReceiver | MarketFactory | — |

---

## 3. Report Payload Summary

| Prefix | Payload | Decode |
|--------|---------|--------|
| `0x03` | `abi.encode(Checkpoint, Delta[], opSig, users[], userSigs[])` | SettlementRouter, ChannelSettlement |
| (none) | `abi.encode(market, marketId, outcomeIndex, confidence)` | CREReceiver, OracleCoordinator |
| `0x04` | `abi.encode(draftId, creator, DraftPublishParams, claimerSig)` | CREPublishReceiver |

---

## 4. References

- [CREReportFormats.md](cre/CREReportFormats.md)
- [CurrentSmartContract.md](CurrentSmartContract.md) §14.2 Concrete Wiring Requirements
