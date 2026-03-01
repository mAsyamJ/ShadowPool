# MarketRiskManager – Frontend Integration (V3)

**Last updated:** 2026-03-01  
**ABI:** `MarketRiskManager.json`  
**Context:** [Frontend.md](Frontend.md) | [CurrentSmartContract.md](../CurrentSmartContract.md)

---

## 1. Contract Purpose

`MarketRiskManager` caps **LP payout exposure** per market. When traders profit (`netTraderDelta > 0`), the LP vault pays; `reserveLpPayout(marketId, amount)` is called before each such payment. The contract enforces `reservedLpPayout + amount <= maxLpPayout` per market. This prevents LP over-exposure and ensures on-chain solvency checks.

**Frontend use:** Optional LP dashboard metrics — show risk utilization per market.

---

## 2. Frontend Relevance

| Feature | User Role | Use Case |
|---------|-----------|----------|
| LP risk metrics | LP | Show cap vs reserved per market |
| Market risk info | Trader (optional) | Understand liquidity depth |

---

## 3. Read Methods (Frontend)

| Method | Params | Returns | Use Case |
|--------|--------|---------|----------|
| `maxLpPayout` | `uint256 marketId` | `uint256` | LP payout cap for market |
| `reservedLpPayout` | `uint256 marketId` | `uint256` | Already reserved (used) |
| `channelSettlement` | — | `address` | Caller of reserveLpPayout |
| `marketFactory` | — | `address` | Caller of setMaxLpPayout |

**Derived:** `availableLpCapacity = maxLpPayout(marketId) - reservedLpPayout(marketId)` — remaining capacity before cap.

---

## 4. Write Methods (Frontend)

None. Frontend is read-only. `reserveLpPayout` and `setMaxLpPayout` are called by ChannelSettlement and MarketFactory respectively.

---

## 5. Events

| Event | Indexed | Use Case |
|-------|---------|----------|
| `MaxLpPayoutSet` | marketId | Cap set at market creation |
| `LpPayoutReserved` | marketId | Reserve on checkpoint finalize |

---

## 6. Errors

| Error | Context |
|-------|---------|
| `RiskCapExceeded` | `reserved + amount > maxLpPayout` — checkpoint finalize would revert |
| `Unauthorized` | Caller not ChannelSettlement or MarketFactory |

---

## 7. Integration Notes

- **Deployment config key:** `MarketRiskManager`
- **Optional:** LP vault detail screens can show `maxLpPayout`, `reservedLpPayout`, and utilization percentage
- Cap is set at publish: `minSeed * marketPolicy.lpExposureMultiplier()` (default multiplier 3)

---

## 8. References

- [ChannelSettlement.md](ChannelSettlement.md) — Calls reserveLpPayout on finalize
- [MarketRegistry.md](MarketRegistry.md) — Market metadata
- [CurrentSmartContract.md](../CurrentSmartContract.md) §14.8 — LP solvency
