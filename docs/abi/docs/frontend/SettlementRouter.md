# SettlementRouter – Frontend Integration

Last updated: 2026-02-20  
ABI: `SettlementRouter.json`  
Context: [Frontend.md](Frontend.md) | [CurrentSmartContract.md](../CurrentSmartContract.md)

---

## 1. Contract Purpose

`SettlementRouter` routes validated outcomes and session payloads from `OracleCoordinator`. It calls `MarketRegistry`/`PoolMarketLegacy` for outcome settlement and `ChannelSettlement` for checkpoint payloads. Backend/infrastructure only.

---

## 2. Frontend Relevance

**Backend / Oracle only.** Frontend does not interact with this contract. Documented for completeness and architecture reference. Resolution and checkpoint finalization flow through here from CRE.

---

## 3. Read Methods (Frontend)

| Method | Params | Returns | Use Case |
|--------|--------|---------|----------|
| `channelSettlement` | — | `address` | Checkpoint routing target |
| `sessionFinalizer` | — | `address` | Legacy fallback |
| `oracleCoordinator` | — | `address` | Caller |
| `approvedMarketReceivers` | `address` | `bool` | Market receiver allowlist |
| `useReceiverAllowlist` | — | `bool` | Use allowlist |
| `owner` | — | `address` | Admin |
| `pendingOwner` | — | `address` | Pending transfer |

---

## 4. Write Methods (Frontend)

None. `settleMarket` and `finalizeSession` are called by `OracleCoordinator` only.

---

## 5. Events

| Event | Indexed Params | Use Case |
|-------|----------------|----------|
| `MarketSettled` | `market` | Market resolved |
| `SessionPayloadRouted` | `target`, `payloadHash`, `marketId` | Checkpoint routed |
| `ChannelSettlementUpdated` | `previous`, `current` | Admin |
| `SessionFinalizerUpdated` | `previous`, `current` | Admin |
| `OracleCoordinatorUpdated` | `previous`, `current` | Admin |
| `OwnershipTransferStarted` | `previousOwner`, `newOwner` | Admin |
| `OwnershipTransferred` | `previousOwner`, `newOwner` | Admin |

---

## 6. Errors

| Error | User-Friendly Message |
|-------|------------------------|
| `Unauthorized` | Only oracle coordinator can call |
| `InvalidAddress` | Invalid address |
| `OwnableInvalidOwner` | Invalid owner |
| `OwnableUnauthorizedAccount` | Unauthorized |

---

## 7. Integration Notes

- No direct frontend integration.
- Pipeline: OracleCoordinator → SettlementRouter → (MarketRegistry | ChannelSettlement | SessionFinalizer).
- Frontend subscribes to `MarketResolved` on MarketRegistry and `CheckpointFinalized` on ChannelSettlement for UX updates.

---

## 8. References

- [OracleCoordinator.md](OracleCoordinator.md) — Upstream
- [ChannelSettlement.md](ChannelSettlement.md) — Checkpoint target
- [MarketRegistry.md](MarketRegistry.md) — Outcome settlement target
- [CurrentSmartContract.md](../CurrentSmartContract.md) — Routing topology
