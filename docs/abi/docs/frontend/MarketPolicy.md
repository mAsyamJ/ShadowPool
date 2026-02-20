# MarketPolicy – Frontend Integration

Last updated: 2026-02-20  
ABI: `MarketPolicy.json`  
Context: [Frontend.md](Frontend.md) | [CurrentSmartContract.md](../CurrentSmartContract.md)

---

## 1. Contract Purpose

`MarketPolicy` validates draft parameters (market type, duration, outcomes, min seed, resolve spec). Used by `MarketDraftBoard` and `MarketFactory` during propose/create. Frontend can read policy values for client-side validation hints and display.

---

## 2. Frontend Relevance

| Feature | User Role | Use Case |
|--------|-----------|----------|
| Validation hints | Creator, Dev | `minCreatorSeed`, `minDuration`, `maxDuration`, `maxOutcomes` |
| Allowed market types | All | `allowedMarketTypes` bitmap |
| Resolve spec allowlist | Dev | `allowedResolveSpecHashes`, `resolveSpecAllowlistEnabled` |

---

## 3. Read Methods (Frontend)

| Method | Params | Returns | Use Case |
|--------|--------|---------|----------|
| `minCreatorSeed` | — | `uint256` | Min seed for claim validation |
| `minDuration` | — | `uint48` | Min duration |
| `maxDuration` | — | `uint48` | Max duration |
| `maxOutcomes` | — | `uint8` | Max outcomes (categorical/timeline) |
| `allowedMarketTypes` | — | `uint256` | Bitmap: Binary, Categorical, Timeline |
| `allowedResolveSpecHashes` | `bytes32 hash` | `bool` | Resolve spec allowed |
| `resolveSpecAllowlistEnabled` | — | `bool` | Use allowlist |
| `MARKET_TYPE_BINARY` | — | `uint8` | 0 |
| `MARKET_TYPE_CATEGORICAL` | — | `uint8` | 1 |
| `MARKET_TYPE_TIMELINE` | — | `uint8` | 2 |
| `validateDraft` | `Draft draft` | — | Reverts if invalid |
| `validateDraftWithOutcomesCount` | `draft`, `outcomesCount` | — | Typed validation |
| `owner` | — | `address` | Admin |

---

## 4. Write Methods (Frontend)

None. Setters are admin-only.

---

## 5. Events

| Event | Indexed Params | Use Case |
|-------|----------------|----------|
| `MinCreatorSeedUpdated` | — | Policy change |
| `MinDurationUpdated` | — | Policy change |
| `MaxDurationUpdated` | — | Policy change |
| `MaxOutcomesUpdated` | — | Policy change |
| `AllowedMarketTypesUpdated` | — | Policy change |
| `ResolveSpecAllowlistEnabledUpdated` | — | Policy change |
| `ResolveSpecAllowlistUpdated` | `hash` | Policy change |
| `OwnershipTransferred` | `previousOwner`, `newOwner` | Admin |

---

## 6. Errors

| Error | User-Friendly Message |
|-------|------------------------|
| `SeedTooLow` | Seed below policy minimum |
| `DurationTooShort` | Duration too short |
| `DurationTooLong` | Duration too long |
| `InvalidMarketType` | Market type not allowed |
| `TooManyOutcomes` | Too many outcomes |
| `ResolveSpecNotAllowed` | Resolve spec not in allowlist |
| `OwnableUnauthorizedAccount` | Unauthorized |

---

## 7. Integration Notes

- Use `minCreatorSeed` for client-side validation before `claimAndSeed`.
- Use `allowedMarketTypes` to show which market types are enabled.
- Policy is read-only for frontend; no deployment config key typically needed.

---

## 8. References

- [MarketDraftBoard.md](MarketDraftBoard.md) — Draft proposal
- [DraftClaimManager.md](DraftClaimManager.md) — Claim validation
- [AppFlow.md](AppFlow.md) — Creator flow
