# ExecutionLedger – Frontend Integration (Deprecated for V3)

Last updated: 2026-03-01  
ABI: `ExecutionLedger.json`  
Context: [Frontend.md](Frontend.md) | [CurrentSmartContract.md](../CurrentSmartContract.md)

---

## Deprecation Notice

**V3 deployments use `OutcomeToken1155` for position tracking.** `ExecutionLedger` is deprecated for the primary production path. Use [OutcomeToken1155.md](OutcomeToken1155.md) instead.

**For position display:** Use `OutcomeToken1155.balanceOf(user, id(marketId, outcomeIndex))` where `id = outcomeToken.id(marketId, outcomeIndex)`.

**Legacy deployments** (e.g. DeployTestnet) may still use ExecutionLedger. This doc is retained for backward compatibility.

---

## 1. Contract Purpose (Legacy)

`ExecutionLedger` stores share positions per user, market, and outcome. Only `ChannelSettlement` can apply deltas. The frontend reads positions for portfolio display and redeem eligibility.

---

## 2. Read Methods (Legacy)

| Method | Params | Returns | Use Case |
|--------|--------|---------|----------|
| `positionOf` | `address user`, `uint256 marketId`, `uint32 outcomeIndex` | `int256` shares | Display position; redeem check |

**Note**: `int256` positive = long that outcome. Binary: outcome 0 = Yes, 1 = No.

---

## 3. References

- [OutcomeToken1155.md](OutcomeToken1155.md) — **Use this for V3**
- [MarketRegistry.md](MarketRegistry.md) — Redeem
- [ChannelSettlement.md](ChannelSettlement.md) — Checkpoint finalization
