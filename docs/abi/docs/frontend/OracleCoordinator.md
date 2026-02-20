# OracleCoordinator – Frontend Integration

Last updated: 2026-02-20  
ABI: `OracleCoordinator.json`  
Context: [Frontend.md](Frontend.md) | [CurrentSmartContract.md](../CurrentSmartContract.md)

---

## 1. Contract Purpose

`OracleCoordinator` receives validated reports from `CREReceiver` and forwards outcome/session payloads to `SettlementRouter`. It is the central oracle routing contract. Only `creReceiver` can call `submitResult`/`submitSession`. Backend/infrastructure only.

---

## 2. Frontend Relevance

**Backend / Oracle only.** Frontend does not interact with this contract. Documented for completeness and architecture reference.

---

## 3. Read Methods (Frontend)

None used by frontend. Config getters (`creReceiver`, `settlementRouter`, `reportValidator`) are for deployment verification.

---

## 4. Write Methods (Frontend)

None. `submitResult` and `submitSession` are called by `CREReceiver` only.

---

## 5. Events

| Event | Indexed Params | Use Case |
|-------|----------------|----------|
| `CREReceiverUpdated` | `previous`, `current` | Admin |
| `SettlementRouterUpdated` | `previous`, `current` | Admin |
| `ReportValidatorUpdated` | `previous`, `current` | Admin |
| `OwnershipTransferred` | `previousOwner`, `newOwner` | Admin |

---

## 6. Errors

| Error | User-Friendly Message |
|-------|------------------------|
| `Unauthorized` | Only creReceiver can call |
| `InvalidConfidence` | Confidence below minimum |
| `OwnableInvalidOwner` | Invalid owner |
| `OwnableUnauthorizedAccount` | Unauthorized |

---

## 7. Integration Notes

- No frontend integration.
- Pipeline: CREReceiver → OracleCoordinator → SettlementRouter.
- `submitResult`: Market outcome resolution.
- `submitSession`: Checkpoint payload for ChannelSettlement.

---

## 8. References

- [CREReceiver.md](CREReceiver.md) — Upstream
- [SettlementRouter.md](SettlementRouter.md) — Downstream
- [ReportValidator.md](ReportValidator.md) — Optional confidence check
- [CurrentSmartContract.md](../CurrentSmartContract.md) — Oracle topology
