# ExecutionLedger – Frontend Integration

Last updated: 2026-02-20  
ABI: `ExecutionLedger.json`  
Context: [Frontend.md](Frontend.md) | [CurrentSmartContract.md](../CurrentSmartContract.md)

---

## 1. Contract Purpose

`ExecutionLedger` stores share positions per user, market, and outcome. Only `ChannelSettlement` can apply deltas. The frontend reads positions for portfolio display and redeem eligibility.

---

## 2. Frontend Relevance

| Feature | User Role | Use Case |
|--------|-----------|----------|
| Position display | Trader | Shares per outcome per market |
| Redeem eligibility | Trader | `positionOf(user, marketId, winningOutcome) > 0` |
| Portfolio | Trader | Aggregated positions across markets |

---

## 3. Read Methods (Frontend)

| Method | Params | Returns | Use Case |
|--------|--------|---------|----------|
| `positionOf` | `address user`, `uint256 marketId`, `uint32 outcomeIndex` | `int256` shares | Display position; redeem check |

**Note**: `int256` positive = long that outcome. Binary: outcome 0 = Yes, 1 = No.

---

## 4. Write Methods (Frontend)

None. `applyDeltas` is called only by `ChannelSettlement` during checkpoint finalization.

---

## 5. Events

| Event | Indexed Params | Use Case |
|-------|----------------|----------|
| `DeltasApplied` | `marketId`, `sessionId` | Position changed; refresh after checkpoint finalize |
| `ChannelSettlementUpdated` | `previous`, `current` | Admin |
| `OwnershipTransferred` | `previousOwner`, `newOwner` | Admin |

---

## 6. Errors

| Error | User-Friendly Message |
|-------|------------------------|
| `NegativePosition` | Invalid position state |
| `OnlyChannelSettlement` | Internal; not user-facing |
| `InvalidAddress` | Invalid address |
| `OwnableUnauthorizedAccount` | Unauthorized |

---

## 7. Integration Notes

- Show free vs locked; `positionOf` is shares only.
- After `CheckpointFinalized`, refresh `positionOf` for affected users.
- **Deployment config key**: `ExecutionLedger`

---

## 8. References

- [MarketRegistry.md](MarketRegistry.md) — Redeem uses `positionOf`
- [ChannelSettlement.md](ChannelSettlement.md) — Checkpoint finalization
- [AppFlow.md](AppFlow.md) — Trading flow
