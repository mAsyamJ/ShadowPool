# FeePool – Frontend Integration

Last updated: 2026-02-20  
ABI: `FeePool.json`  
Context: [Frontend.md](Frontend.md) | [CurrentSmartContract.md](../CurrentSmartContract.md)

---

## 1. Contract Purpose

`FeePool` collects protocol fees from `ChannelSettlement`. Only `feeCollector` (typically `ChannelSettlement`) can record fees. Admin can sweep to `TreasuryPool`. Frontend typically has minimal interaction; display for admin dashboards.

---

## 2. Frontend Relevance

| Feature | User Role | Use Case |
|--------|-----------|----------|
| Fee balance display | Admin | `balanceOf(asset)` |
| Config | Dev | `feeCollector`, `treasuryPool` |

---

## 3. Read Methods (Frontend)

| Method | Params | Returns | Use Case |
|--------|--------|---------|----------|
| `balanceOf` | `address asset` | `uint256` | Protocol fee balance per asset |
| `feeCollector` | — | `address` | ChannelSettlement |
| `treasuryPool` | — | `address` | TreasuryPool |
| `owner` | — | `address` | Admin |

---

## 4. Write Methods (Frontend)

None. `recordFeeCollected` called by `ChannelSettlement`; `sweepToTreasury` admin-only.

---

## 5. Events

| Event | Indexed Params | Use Case |
|-------|----------------|----------|
| `FeeCollected` | `asset`, `marketId`, `sessionId` | Fee recorded |
| `SweptToTreasury` | `asset` | Sweep to treasury |
| `FeeCollectorUpdated` | `previous`, `current` | Admin |
| `TreasuryPoolUpdated` | `previous`, `current` | Admin |
| `OwnershipTransferred` | `previousOwner`, `newOwner` | Admin |

---

## 6. Errors

| Error | User-Friendly Message |
|-------|------------------------|
| `OnlyFeeCollector` | Internal |
| `InvalidAddress` | Invalid address |
| `TreasuryNotSet` | Treasury not configured |
| `SafeERC20FailedOperation` | Transfer failed |
| `OwnableUnauthorizedAccount` | Unauthorized |

---

## 7. Integration Notes

- Admin dashboard may show `balanceOf(asset)` for protocol fees.
- `feeCollector` must be `ChannelSettlement` for protocol fee collection to work.
- Not typically a deployment config key for user-facing frontend.

---

## 8. References

- [ChannelSettlement.md](ChannelSettlement.md) — Fee collector
- [FeeManager.md](FeeManager.md) — Fee computation
- [TreasuryPool.md](TreasuryPool.md) — Sweep destination
