# DraftClaimManager – Frontend Integration

Last updated: 2026-02-20  
ABI: `DraftClaimManager.json`  
Context: [Frontend.md](Frontend.md) | [CurrentSmartContract.md](../CurrentSmartContract.md)

---

## 1. Contract Purpose

`DraftClaimManager` enables creators to claim and seed market drafts. The `claimAndSeed` path locks seed in a per-draft ERC-4626 liquidity vault until `tradingClose`, then `unlockSeedShares` returns shares to the creator.

---

## 2. Frontend Relevance

| Feature | User Role | Use Case |
|--------|-----------|----------|
| Claim & seed | Creator/Curator | Claim modal with EIP-712 signing |
| Unlock seed shares | Creator | After `tradingClose`; "Unlock Seed Shares" CTA |
| Liquidity vault lookup | LP, Creator | Vault address for deposit or LP display |

---

## 3. Read Methods (Frontend)

| Method | Params | Returns | Use Case |
|--------|--------|---------|----------|
| `getLiquidityVault` | `bytes32 draftId` | `address` | Vault address for LP deposit or display |
| `getClaimer` | `bytes32 draftId` | `address` | Creator of claimed draft |
| `getClaim` | `bytes32 draftId` | `Claim` tuple | Claim metadata |
| `seedSharesLocked` | `bytes32 draftId` | `uint256` | Shares locked; show before unlock |
| `seedUnlockTime` | `bytes32 draftId` | `uint48` | Unlock eligible when `block.timestamp >=` |
| `nonces` | `address user` | `uint256` | EIP-712 nonce for `claimAndSeed` |
| `digestClaimAndSeed` | `draftId`, `asset`, `seedAmount`, `deadline`, `signer` | `bytes32` | EIP-712 digest (optional; can compute client-side) |
| `liquidityVaultByDraftId` | `bytes32 draftId` | `address` | Same as `getLiquidityVault` |
| `claimTypeByDraftId` | `bytes32 draftId` | `uint8` | Claim type (legacy vs seeded) |
| `claims` | `bytes32 draftId` | `Claim` tuple | Claim data |
| `liquidityVaultFactory` | — | `address` | Factory reference |

---

## 4. Write Methods (Frontend)

| Method | Params | When Called | Pre-conditions |
|--------|--------|-------------|----------------|
| `claimAndSeed` | `draftId`, `asset`, `seedAmount`, `deadline`, `sig` | Creator claims draft and seeds | 1. `asset.approve(DraftClaimManager, seedAmount)` 2. EIP-712 sign 3. `seedAmount >= draft.minSeed` 4. `asset == draft.settlementAsset` (or draft has no asset) |
| `unlockSeedShares` | `bytes32 draftId` | After `tradingClose` | `block.timestamp >= seedUnlockTime(draftId)`, `seedSharesLocked > 0` |

**Legacy path** (demo): `claimDraft(draftId, bond, seedCommitment, expiry, sig)` — no seed deposit.

---

## 5. Events

| Event | Indexed Params | Use Case |
|-------|----------------|----------|
| `DraftClaimedAndSeeded` | `draftId`, `claimer`, `vault` | Confirm claim success; refresh draft status |
| `SeedSharesUnlocked` | `draftId`, `claimer` | Confirm unlock; refresh LP balance |
| `DraftClaimed` | `draftId`, `claimer` | Legacy claim |
| `LiquidityVaultFactoryUpdated` | `previous`, `current` | Admin change |
| `EIP712DomainChanged` | — | Rare config change |
| `OwnershipTransferred` | `previousOwner`, `newOwner` | Admin |

---

## 6. Errors

| Error | User-Friendly Message |
|-------|------------------------|
| `DraftNotProposed` | This draft is no longer available to claim |
| `SeedTooLow` | Seed amount must be at least {minSeed} |
| `AssetMismatch` | Selected token does not match market settlement asset |
| `ClaimExpired` | Claim window has expired |
| `InvalidSignature` | Signature invalid or expired; try again |
| `DraftDoesNotExist` | Draft not found |
| `VaultFactoryNotSet` | System configuration error; try later |
| `SeedNotLocked` | No locked shares to unlock |
| `UnlockTimeNotReached` | Seed unlock not yet available; wait until after trading close |
| `ECDSAInvalidSignature` | Invalid signature |
| `ECDSAInvalidSignatureLength` | Invalid signature format |
| `SafeERC20FailedOperation` | Token transfer failed |
| `OwnableUnauthorizedAccount` | Unauthorized |

---

## 7. Integration Notes

### EIP-712 ClaimAndSeed

- **Domain**: `DraftClaimManager`, version `1`
- **TypeHash**: `ClaimAndSeed(bytes32 draftId,address asset,uint256 seedAmount,uint256 deadline,uint256 nonce)`
- **Nonce**: `draftClaimManager.nonces(user)`
- **Digest**: Use `digestClaimAndSeed(draftId, asset, seedAmount, deadline, user)` or compute client-side

### UX

- Explain seed is locked until `tradingClose`.
- Show "Unlock seed shares" when `block.timestamp >= draft.tradingClose`.
- Read `seedSharesLocked` and `seedUnlockTime` before unlock.
- **Deployment config key**: `DraftClaimManager`

---

## 8. References

- [MarketDraftBoard.md](MarketDraftBoard.md) — Draft data
- [LiquidityVaultFactory.md](LiquidityVaultFactory.md) — Vault deployment
- [CREPublishReceiver.md](CREPublishReceiver.md) — Publish (creator signs when relayer requests)
- [AppFlow.md](AppFlow.md) — Creator flow
