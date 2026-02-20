# ReportValidator – Frontend Integration

Last updated: 2026-02-20  
ABI: `ReportValidator.json`  
Context: [Frontend.md](Frontend.md) | [CurrentSmartContract.md](../CurrentSmartContract.md)

---

## 1. Contract Purpose

`ReportValidator` optionally validates oracle report confidence. `OracleCoordinator` can use it to reject reports below `minConfidence`. Backend/infrastructure only.

---

## 2. Frontend Relevance

**Backend / Oracle only.** Frontend does not interact with this contract. Documented for completeness and architecture reference.

---

## 3. Read Methods (Frontend)

| Method | Params | Returns | Use Case |
|--------|--------|---------|----------|
| `minConfidence` | — | `uint16` | Minimum confidence threshold |
| `validate` | `uint16 confidence` | — | Reverts if below min |
| `owner` | — | `address` | Admin |

---

## 4. Write Methods (Frontend)

None. `setMinConfidence` admin-only.

---

## 5. Events

| Event | Indexed Params | Use Case |
|-------|----------------|----------|
| `MinConfidenceUpdated` | — | Policy change |
| `OwnershipTransferred` | `previousOwner`, `newOwner` | Admin |

---

## 6. Errors

| Error | User-Friendly Message |
|-------|------------------------|
| `InvalidConfidence` | Confidence below minimum |
| `OwnableInvalidOwner` | Invalid owner |
| `OwnableUnauthorizedAccount` | Unauthorized |

---

## 7. Integration Notes

- No frontend integration.
- Used by OracleCoordinator when `reportValidator` is set.
- Market resolution can fail if oracle confidence is below `minConfidence`.

---

## 8. References

- [OracleCoordinator.md](OracleCoordinator.md) — Uses ReportValidator
- [CurrentSmartContract.md](../CurrentSmartContract.md) — Oracle topology
- [AppFlow.md](AppFlow.md) — Resolution flow
