# CollateralVault – Frontend Integration

Last updated: 2026-02-20  
ABI: `CollateralVault.json`  
Context: [Frontend.md](Frontend.md) | [CurrentSmartContract.md](../CurrentSmartContract.md)

---

## 1. Contract Purpose

`CollateralVault` holds single-asset collateral for traders. Users deposit and withdraw; `ChannelSettlement` locks/unlocks during checkpoint settlement. Used when deployment uses single-asset mode (no `MultiAssetVault`).

---

## 2. Frontend Relevance

| Feature | User Role | Use Case |
|--------|-----------|----------|
| Deposit | Trader | Add collateral before trading |
| Withdraw | Trader | Remove free balance |
| Balance display | Trader | Free vs locked balance |

---

## 3. Read Methods (Frontend)

| Method | Params | Returns | Use Case |
|--------|--------|---------|----------|
| `freeBalance` | `address user` | `uint256` | Available balance |
| `lockedBalance` | `address user`, `uint256 marketId`, `bytes32 sessionId` | `uint256` | Locked in session |
| `token` / `TOKEN_CONTRACT` | — | `address` | Underlying ERC20 |
| `channelSettlement` | — | `address` | Settlement contract |
| `marketRegistry` | — | `address` | Registry for redeem |

---

## 4. Write Methods (Frontend)

| Method | Params | When Called | Pre-conditions |
|--------|--------|-------------|----------------|
| `deposit` | `uint256 amount` | User adds collateral | `token.approve(CollateralVault, amount)` |
| `withdraw` | `uint256 amount` | User removes collateral | `amount <= freeBalance(user)` |

`applyCashDeltas`, `lock`, `unlock`, `redeemPayout`, `transferToFeeCollector` are called only by `ChannelSettlement` or `MarketRegistry`.

---

## 5. Events

| Event | Indexed Params | Use Case |
|-------|----------------|----------|
| `Deposited` | `user` | Balance refresh |
| `Withdrawn` | `user` | Balance refresh |
| `CashDeltasApplied` | `marketId`, `sessionId` | Position/balance changed after checkpoint |
| `Locked` | `user` | Lock applied |
| `Unlocked` | `user` | Unlock applied |
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

- Show free vs locked; per-user only (single asset).
- Approve `token` to `CollateralVault` before `deposit`.
- **Deployment config key**: `CollateralVault`

---

## 8. References

- [MultiAssetVault.md](MultiAssetVault.md) — Multi-asset alternative
- [ChannelSettlement.md](ChannelSettlement.md) — Checkpoint settlement
- [MarketRegistry.md](MarketRegistry.md) — Redeem payout
- [AppFlow.md](AppFlow.md) — Trader flow
