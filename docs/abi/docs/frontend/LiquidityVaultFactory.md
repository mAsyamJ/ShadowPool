# LiquidityVaultFactory – Frontend Integration

Last updated: 2026-02-20  
ABI: `LiquidityVaultFactory.json`  
Context: [Frontend.md](Frontend.md) | [CurrentSmartContract.md](../CurrentSmartContract.md)

---

## 1. Contract Purpose

`LiquidityVaultFactory` deploys and looks up per-draft ERC-4626 liquidity vaults. `DraftClaimManager` uses it during `claimAndSeed`; frontend typically gets vault address from `DraftClaimManager.getLiquidityVault(draftId)` or `MarketRegistry.liquidityVaultByMarketId(marketId)`.

---

## 2. Frontend Relevance

| Feature | User Role | Use Case |
|--------|-----------|----------|
| Vault lookup | LP, Creator | `getVaultForDraft(draftId)` when `DraftClaimManager` is not used |
| Config | Dev | `channelSettlement` for vault settlement hook |

---

## 3. Read Methods (Frontend)

| Method | Params | Returns | Use Case |
|--------|--------|---------|----------|
| `getVaultForDraft` | `bytes32 draftId` | `address` | Vault address for draft |
| `vaultByDraftId` | `bytes32 draftId` | `address` | Same as `getVaultForDraft` |
| `channelSettlement` | — | `address` | ChannelSettlement (vault payToTradingLedger caller) |
| `owner` | — | `address` | Admin |

---

## 4. Write Methods (Frontend)

None. `createVaultForDraft` is called by `DraftClaimManager` during `claimAndSeed`. Frontend does not call it.

---

## 5. Events

| Event | Indexed Params | Use Case |
|-------|----------------|----------|
| `VaultCreated` | `draftId`, `vault` | New vault for draft |
| `ChannelSettlementUpdated` | `previous`, `current` | Admin |
| `OwnershipTransferred` | `previousOwner`, `newOwner` | Admin |

---

## 6. Errors

| Error | User-Friendly Message |
|-------|------------------------|
| `OwnableInvalidOwner` | Invalid owner |
| `OwnableUnauthorizedAccount` | Unauthorized |

---

## 7. Integration Notes

- Prefer `DraftClaimManager.getLiquidityVault(draftId)` for vault lookup after claim.
- For post-publish: `MarketRegistry.liquidityVaultByMarketId(marketId)`.
- **Deployment config key**: `LiquidityVaultFactory` (for vault resolution if needed)

---

## 8. References

- [DraftClaimManager.md](DraftClaimManager.md) — Claim flow, `getLiquidityVault`
- [MarketRegistry.md](MarketRegistry.md) — `liquidityVaultByMarketId`
- [AppFlow.md](AppFlow.md) — LP vault flow
