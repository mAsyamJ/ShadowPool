# TreasuryPool – Frontend Integration

Last updated: 2026-02-20  
ABI: `TreasuryPool.json`  
Context: [Frontend.md](Frontend.md) | [CurrentSmartContract.md](../CurrentSmartContract.md)

---

## 1. Contract Purpose

`TreasuryPool` receives protocol fees swept from `FeePool` and LP fee fallback when no LP vault exists. Admin can `spend` to withdraw. Frontend typically has minimal interaction; admin dashboards only.

---

## 2. Frontend Relevance

| Feature | User Role | Use Case |
|--------|-----------|----------|
| Treasury balance | Admin | `balanceOf(asset)` |
| Spend history | Admin | `Spent` events |

---

## 3. Read Methods (Frontend)

| Method | Params | Returns | Use Case |
|--------|--------|---------|----------|
| `balanceOf` | `address asset` | `uint256` | Treasury balance per asset |
| `owner` | — | `address` | Admin |

---

## 4. Write Methods (Frontend)

None. `receiveSweep` called by FeePool; `spend` admin-only.

---

## 5. Events

| Event | Indexed Params | Use Case |
|-------|----------------|----------|
| `ReceivedSweep` | `asset` | Sweep received |
| `Spent` | `asset`, `to` | Spend executed |
| `OwnershipTransferred` | `previousOwner`, `newOwner` | Admin |

---

## 6. Errors

| Error | User-Friendly Message |
|-------|------------------------|
| `InsufficientBalance` | Insufficient treasury balance |
| `InvalidAddress` | Invalid address |
| `SafeERC20FailedOperation` | Transfer failed |
| `OwnableUnauthorizedAccount` | Unauthorized |

---

## 7. Integration Notes

- Admin-only contract. No user-facing frontend integration.
- Not a deployment config key for standard frontend.

---

## 8. References

- [FeePool.md](FeePool.md) — Sweeps to TreasuryPool
- [ChannelSettlement.md](ChannelSettlement.md) — LP fee fallback when no vault
