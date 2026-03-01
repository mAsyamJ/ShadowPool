# Contract Error → User Message Reference

**Last updated:** 2026-03-01  
**Context:** [Frontend.md](Frontend.md) | [ABIRefERENCE.md](ABIRefERENCE.md)

---

## 1. Overview

When a contract reverts, the frontend should map the error to a user-friendly message. This reference covers frontend-relevant contracts.

**Error detection:** Use `decodeErrorResult` (viem) or `parseError` (ethers) on the revert data. Match by error selector or name.

---

## 2. DraftClaimManager

| Error | User Message |
|-------|--------------|
| `DraftDoesNotExist` | This draft no longer exists |
| `DraftNotProposed` | This draft is no longer available to claim |
| `InvalidSignature` | Signature invalid or expired; try again |
| `ClaimExpired` | Claim window has expired |
| `SeedTooLow` | Seed amount must be at least {minSeed} |
| `AssetMismatch` | Selected token does not match market settlement asset |
| `VaultFactoryNotSet` | System configuration error; try again later |
| `SeedNotLocked` | No seed shares to unlock |
| `UnlockTimeNotReached` | Seed shares unlock after market trading closes |

---

## 3. MarketRegistry

| Error | User Message |
|-------|--------------|
| `NothingToRedeem` | No winning shares to redeem |
| `AlreadyRedeemed` | Winnings already claimed |
| `MarketNotSettled` | Market has not been resolved yet |
| `MarketDoesNotExist` | Market not found |
| `MarketAlreadySettled` | Market already resolved |
| `InvalidOutcomeIndex` | Invalid outcome |
| `InvalidOutcomeCount` | Invalid outcome count |
| `InvalidTimelineWindows` | Invalid timeline configuration |
| `InvalidAddress` | Invalid address |
| `TransferFailed` | Payout transfer failed; try again |
| `InvalidMarketTimes` | Invalid timing |

---

## 4. OutcomeToken1155

| Error | User Message |
|-------|--------------|
| `TransferLocked` | Cannot transfer outcome tokens until market is resolved |
| `ERC1155InsufficientBalance` | Insufficient balance |
| `ERC1155InvalidReceiver` | Invalid receiver address |
| `ERC1155MissingApprovalForAll` | Approve operator first |

---

## 5. CollateralVault / MultiAssetVault

| Error | User Message |
|-------|--------------|
| `InsufficientFreeBalance` | Not enough balance; deposit first |
| `InsufficientAvailableBalance` | Cannot withdraw: amount reserved for pending settlement |
| `InsufficientLockedBalance` | Insufficient locked balance |
| `NegativeResult` | Internal error |
| `OnlyChannelSettlement` | Unauthorized (internal) |
| `OnlyMarketRegistry` | Unauthorized (internal) |

---

## 6. ChannelSettlement (Relayer / CRE Context)

Users typically do not call ChannelSettlement directly. These errors may appear in relayer or CRE logs:

| Error | Meaning |
|-------|---------|
| `BadDeltasHash` | Checkpoint payload hash mismatch |
| `BadOperatorSig` | Operator signature invalid |
| `BadUserSig` | User signature invalid |
| `DeltaUserNotSigned` | A user in the checkpoint did not sign |
| `DuplicateUsers` | Duplicate signers in list |
| `NonceNotIncreasing` | Stale or replayed checkpoint |
| `ChallengeWindow` | Cannot finalize during challenge window |
| `CheckpointAfterTradingClose` | Checkpoint timestamp after trading close |
| `LiquidityVaultRequired` | LP vault required but not set |
| `LpVaultInsolvent(need, have)` | LP vault insufficient to pay traders |
| `RiskCapExceeded` | LP payout cap exceeded |
| `InsufficientAvailableBalance` | User withdrew reserved balance |
| `CancelTooEarly` | Cannot cancel; wait for cancel window |

---

## 7. Faucet

| Error | User Message |
|-------|--------------|
| `InvalidState` | Cannot claim: token disabled or cooldown not elapsed |
| `InvalidAmount` | Faucet balance too low; try again later |
| `InvalidAddress` | Invalid token address |

---

## 8. PoolMarketLegacy (Demo Only)

| Error | User Message |
|-------|--------------|
| `WrongOutcomeToAdd` | Reduce current position before changing outcome |
| `CannotReduceMoreThanPosition` | Amount exceeds your position |
| `NothingToClaim` | No winnings to claim |
| `AlreadyClaimed` | Winnings already claimed |
| `MarketNotSettled` | Market has not been resolved yet |
| `InvalidAmount` | Invalid amount |

---

## 9. MarketDraftBoard

| Error | User Message |
|-------|--------------|
| `DraftDoesNotExist` | Draft not found |
| `DraftNotProposed` | Draft not in Proposed state |
| `DraftNotClaimed` | Draft must be claimed first |
| `DraftAlreadyPublished` | Draft already published |
| `DraftAlreadyCancelled` | Draft was cancelled |
| `DraftAlreadyExpired` | Draft has expired |
| `UnauthorizedCaller` | Unauthorized |
| `InvalidOutcomeCount` | Invalid outcome count |
| `InvalidTimelineWindows` | Invalid timeline |

---

## 10. CREPublishReceiver / MarketFactory

| Error | User Message |
|-------|--------------|
| `DraftNotClaimed` | Draft must be claimed and seeded first |
| `InvalidCreator` | Creator does not match claimer |
| `InvalidSignature` | Publish signature invalid |
| `InvalidParamsHash` | Publish params hash mismatch |
| `UnauthorizedPublishReceiver` | Unauthorized publish |
| `CuratedPathNotConfigured` | System configuration error |
| `DraftTimeMismatch` | Draft times cannot be overridden |
| `SeededClaimRequired` | Draft must be seeded before publish |
| `InvalidLiquidityVaultAsset` | Liquidity vault asset mismatch |

---

## 11. Generic (Shared)

| Error | User Message |
|-------|--------------|
| `Unauthorized` | Unauthorized action |
| `InvalidAddress` | Invalid address |
| `InvalidAmount` | Invalid amount |
| `TransferFailed` | Transfer failed; try again |

---

## 12. Error Handling Pattern (viem)

```ts
import { decodeErrorResult } from 'viem';

try {
  await contract.write.redeem([marketId]);
} catch (e: any) {
  if (e.cause?.data) {
    const decoded = decodeErrorResult({
      abi: contract.abi,
      data: e.cause.data,
    });
    const msg = ERROR_MESSAGES[decoded.errorName] ?? 'Transaction failed';
    showToast(msg);
  }
}
```

---

## 13. References

- [Frontend.md](Frontend.md) §8 — Client-side validation
- [ABIRefERENCE.md](ABIRefERENCE.md) — Contract methods
- [src/utils/Errors.sol](../../src/utils/Errors.sol) — Error definitions
