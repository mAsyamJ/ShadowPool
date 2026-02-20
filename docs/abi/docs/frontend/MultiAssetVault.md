# MultiAssetVault – Frontend Integration

Last updated: 2026-02-20  
ABI: `MultiAssetVault.json`  
Context: [Frontend.md](Frontend.md) | [CurrentSmartContract.md](../CurrentSmartContract.md)

---

## 1. Contract Purpose

`MultiAssetVault` holds multi-asset collateral per user and asset. Used when deployment supports multiple settlement assets. Users deposit/withdraw per asset; `ChannelSettlement` locks/unlocks during checkpoint settlement.

---

## 2. Frontend Relevance

| Feature | User Role | Use Case |
|--------|-----------|----------|
| Deposit | Trader | Add collateral (per asset) |
| Withdraw | Trader | Remove free balance (per asset) |
| Balance display | Trader | Free vs locked per asset |

---

## 3. Read Methods (Frontend)

| Method | Params | Returns | Use Case |
|--------|--------|---------|----------|
| `freeBalance` | `address user`, `address asset` | `uint256` | Available balance for asset |
| `lockedBalance` | `user`, `asset`, `marketId`, `sessionId` | `uint256` | Locked in session |
| `channelSettlement` | — | `address` | Settlement contract |
| `marketRegistry` | — | `address` | Registry for redeem |

---

## 4. Write Methods (Frontend)

| Method | Params | When Called | Pre-conditions |
|--------|--------|-------------|----------------|
| `deposit` | `address asset`, `uint256 amount` | User adds collateral | `asset.approve(MultiAssetVault, amount)` |
| `withdraw` | `address asset`, `uint256 amount` | User removes collateral | `amount <= freeBalance(user, asset)` |

`applyCashDeltas`, `lock`, `unlock`, `redeemPayout`, `transferAsset`, `transferToFeeCollector` are called only by `ChannelSettlement` or `MarketRegistry`.

---

## 5. Events

| Event | Indexed Params | Use Case |
|-------|----------------|----------|
| `Deposited` | `user`, `asset` | Balance refresh |
| `Withdrawn` | `user`, `asset` | Balance refresh |
| `CashDeltasApplied` | `asset`, `marketId`, `sessionId` | Position/balance changed after checkpoint |
| `Locked` | `user`, `asset` | Lock applied |
| `Unlocked` | `user`, `asset` | Unlock applied |
| `ChannelSettlementUpdated` | `previous`, `current` | Admin |
| `MarketRegistryUpdated` | `previous`, `current` | Admin |
| `OwnershipTransferred` | `previousOwner`, `newOwner` | Admin |

---

## 6. Errors

| Error | User-Friendly Message |
|-------|------------------------|
| `InsufficientFreeBalance` | Not enough balance; deposit first |
| `InsufficientLockedBalance` | Insufficient locked balance |
| `InvalidAddress` | Invalid address |
| `InvalidAmount` | Invalid amount |
| `NegativeResult` | Internal error |
| `OnlyChannelSettlement` | Internal |
| `OnlyMarketRegistry` | Internal |
| `SafeCastOverflowedIntToUint` | Internal error |
| `SafeERC20FailedOperation` | Token transfer failed |
| `OwnableUnauthorizedAccount` | Unauthorized |

---

## 7. Integration Notes

- Show free vs locked per asset.
- Settlement asset per market: `MarketRegistry.getSettlementAsset(marketId)`.
- Approve each asset before `deposit`.
- **Deployment config key**: `MultiAssetVault`

---

## 8. References

- [CollateralVault.md](CollateralVault.md) — Single-asset alternative
- [ChannelSettlement.md](ChannelSettlement.md) — Checkpoint settlement
- [MarketRegistry.md](MarketRegistry.md) — Redeem, settlement asset
- [AppFlow.md](AppFlow.md) — Trader flow
