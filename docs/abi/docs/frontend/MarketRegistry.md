# MarketRegistry – Frontend Integration

Last updated: 2026-02-20  
ABI: `MarketRegistry.json`  
Context: [Frontend.md](Frontend.md) | [CurrentSmartContract.md](../CurrentSmartContract.md)

---

## 1. Contract Purpose

`MarketRegistry` is the canonical source for market metadata, status, settlement, and redemption. It holds market structs, resolves via oracle, and pays winners from the configured vault. Markets are created via `MarketFactory` (curated path).

---

## 2. Frontend Relevance

| Feature | User Role | Use Case |
|--------|-----------|----------|
| Market list/detail | All | Browse, filter by status |
| Redeem | Trader | Claim winnings when resolved |
| Market metadata | All | Question, outcomes, timing, settlement asset |
| LP vault link | LP | `liquidityVaultByMarketId` |

---

## 3. Read Methods (Frontend)

| Method | Params | Returns | Use Case |
|--------|--------|---------|----------|
| `getMarket` | `uint256 marketId` | `Market` struct | Market detail |
| `status` | `uint256 marketId` | `uint8` (Status) | Open, Frozen, Resolved, etc. |
| `marketType` | `uint256 marketId` | `uint8` | Binary (0), Categorical (1), Timeline (2) |
| `getTradingClose` | `uint256 marketId` | `uint48` | Trading close time |
| `getSettlementAsset` | `uint256 marketId` | `address` | Settlement token |
| `getCreator` | `uint256 marketId` | `address` | Creator address |
| `getCategoricalOutcomes` | `uint256 marketId` | `string[]` | Categorical market outcomes |
| `getTimelineWindows` | `uint256 marketId` | `uint48[]` | Timeline windows |
| `typedOutcomeIndex` | `uint256 marketId` | `uint32` | Winning outcome index after resolve |
| `liquidityVaultByMarketId` | `uint256 marketId` | `address` | LP vault for market |
| `settlementAssetByMarketId` | `uint256 marketId` | `address` | Per-market settlement asset |
| `defaultSettlementAsset` | — | `address` | Default when not set per market |
| `multiAssetVault` | — | `address` | MAV if used |
| `usesLpVaultByMarketId` | `uint256 marketId` | `bool` | LP vault flag |

**Market struct**: `creator`, `createdAt`, `expiry`, `tradingOpen`, `tradingClose`, `resolveTime`, `settledAt`, `settled`, `frozen`, `confidence`, `outcome`, `question`

**Status derivation**: Draft → Open → Frozen → Resolved | Closed

---

## 4. Write Methods (Frontend)

| Method | Params | When Called | Pre-conditions |
|--------|--------|-------------|----------------|
| `redeem` | `uint256 marketId` | User claims winnings | Market resolved; `positionOf(user, marketId, winningOutcome) > 0`; user not yet redeemed (track via `Redeemed` events) |
| `freeze` | `uint256 marketId` | Permissionless | `block.timestamp >= tradingClose`; sets frozen |

All other write methods (`create*`, `resolve`, `setLiquidityVault`, etc.) are called by factory, settlement router, or admin.

---

## 5. Events

| Event | Indexed Params | Use Case |
|-------|----------------|----------|
| `MarketCreated` | `marketId` | Append to market list; index from block 0 |
| `MarketCreatedTyped` | `marketId` | Typed market created |
| `MarketResolved` | `marketId` | Enable "Claim winnings" UI |
| `Redeemed` | `marketId`, `user` | Confirm payout; track if user already redeemed |
| `OwnershipTransferred` | `previousOwner`, `newOwner` | Admin |

---

## 6. Errors

| Error | User-Friendly Message |
|-------|------------------------|
| `NothingToRedeem` | No winning shares to redeem |
| `AlreadyRedeemed` | Winnings already claimed |
| `MarketNotSettled` | Market has not been resolved yet |
| `MarketDoesNotExist` | Market not found |
| `MarketAlreadySettled` | Market already resolved |
| `InvalidOutcomeIndex` | Invalid outcome |
| `InvalidOutcomeCount` | Invalid outcome count |
| `InvalidTimelineWindows` | Invalid timeline |
| `InvalidAddress` | Invalid address |
| `TransferFailed` | Payout transfer failed |
| `UnauthorizedFactory` | Unauthorized |
| `UnauthorizedRouter` | Unauthorized |
| `SafeCastOverflowedIntToUint` | Internal error |
| `OwnableUnauthorizedAccount` | Unauthorized |
| `InvalidMarketTimes` | Invalid timing |

---

## 7. Integration Notes

- **Market list**: No `marketCount`. Use event indexer, subgraph, or backend API.
- **Redeem**: One-shot per (marketId, user). Track `Redeemed` events for `hasRedeemed`.
- **Winning outcome**: Binary uses `market.outcome`; typed uses `typedOutcomeIndex(marketId)`.
- **Deployment config key**: `MarketRegistry`

---

## 8. References

- [ExecutionLedger.md](ExecutionLedger.md) — `positionOf` for redeem check
- [CollateralVault.md](CollateralVault.md) / [MultiAssetVault.md](MultiAssetVault.md) — Payout source
- [MarketFactory.md](MarketFactory.md) — `draftIdByMarketId`
- [AppFlow.md](AppFlow.md) — Trader flow
