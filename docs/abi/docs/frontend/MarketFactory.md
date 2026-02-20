# MarketFactory – Frontend Integration

Last updated: 2026-02-20  
ABI: `MarketFactory.json`  
Context: [Frontend.md](Frontend.md) | [CurrentSmartContract.md](../CurrentSmartContract.md)

---

## 1. Contract Purpose

`MarketFactory` creates markets via CRE and curated `createFromDraft`. It is the bridge between drafts and live markets. `CREPublishReceiver` calls `createFromDraft`; frontend reads `draftIdByMarketId` and optional market metadata.

---

## 2. Frontend Relevance

| Feature | User Role | Use Case |
|--------|-----------|----------|
| Draft–market link | All | `draftIdByMarketId(marketId)` for curated markets |
| Market metadata | All | `marketMetadata(marketId)` optional metadata tuple |
| Market type constants | Dev | `MARKET_TYPE_BINARY`, `MARKET_TYPE_CATEGORICAL`, `MARKET_TYPE_TIMELINE` |

---

## 3. Read Methods (Frontend)

| Method | Params | Returns | Use Case |
|--------|--------|---------|----------|
| `draftIdByMarketId` | `uint256 marketId` | `bytes32 draftId` | Link market to draft (curated path) |
| `marketMetadata` | `uint256 marketId` | `tuple` | Optional metadata |
| `draftBoard` | — | `address` | MarketDraftBoard |
| `draftClaimManager` | — | `address` | DraftClaimManager |
| `marketRegistry` | — | `address` | MarketRegistry |
| `PREDICTION_MARKET` | — | `address` | PoolMarketLegacy (legacy) |
| `MARKET_TYPE_BINARY` | — | `uint8` | 0 |
| `MARKET_TYPE_CATEGORICAL` | — | `uint8` | 1 |
| `MARKET_TYPE_TIMELINE` | — | `uint8` | 2 |
| `approvedPublishReceivers` | `address` | `bool` | Is receiver approved |
| `usedExternalIds` | `bytes32` | `bool` | External ID used |
| `maxQuestionLength` | — | `uint256` | Validation |
| `minQuestionLength` | — | `uint256` | Validation |
| `getForwarderAddress` | — | `address` | CRE |
| `getExpectedAuthor` | — | `address` | Optional |
| `getExpectedWorkflowId` | — | `bytes32` | Optional |
| `getExpectedWorkflowName` | — | `bytes10` | Optional |
| `owner` | — | `address` | Admin |

---

## 4. Write Methods (Frontend)

None. `createFromDraft`, `onReport`, and setters are called by `CREPublishReceiver`, CRE, or admin.

---

## 5. Events

| Event | Indexed Params | Use Case |
|-------|----------------|----------|
| `MarketSpawned` | `marketId`, `requestedBy` | Market created |
| `MarketSpawnedTyped` | `marketId`, `requestedBy` | Typed market created |
| `ExpectedAuthorUpdated` | `previousAuthor`, `newAuthor` | Admin |
| `ExpectedWorkflowIdUpdated` | `previousId`, `newId` | Admin |
| `ExpectedWorkflowNameUpdated` | `previousName`, `newName` | Admin |
| `ForwarderAddressUpdated` | `previousForwarder`, `newForwarder` | Admin |
| `OwnershipTransferred` | `previousOwner`, `newOwner` | Admin |
| `SecurityWarning` | — | Security |

---

## 6. Errors

| Error | User-Friendly Message |
|-------|------------------------|
| `CuratedPathNotConfigured` | Curated path not set up |
| `DraftTimeMismatch` | Draft times don't match |
| `SeededClaimRequired` | Draft must be claimed with seed |
| `UnauthorizedPublishReceiver` | Unauthorized publish receiver |
| `InvalidLiquidityVaultAsset` | LP vault asset mismatch |
| `InvalidQuestion` | Invalid question |
| `InvalidMarketType` | Invalid market type |
| `InvalidOutcomeCount` | Invalid outcome count |
| `InvalidTimelineWindows` | Invalid timeline |
| `InvalidRequestedBy` | Invalid creator |
| `InvalidSignature` | Invalid signature |
| `InvalidSender` | Invalid sender |
| `InvalidWorkflowId` | Workflow mismatch |
| `InvalidWorkflowName` | Workflow name mismatch |
| `ResolveTimeInPast` | Resolve time in past |
| `DuplicateExternalId` | Duplicate external ID |
| `InvalidMarketAddress` | Invalid market |
| `InvalidForwarderAddress` | Invalid forwarder |
| `ECDSAInvalidSignature` | Invalid signature |
| `OwnableUnauthorizedAccount` | Unauthorized |
| `WorkflowNameRequiresAuthorValidation` | Config error |

---

## 7. Integration Notes

- Use `draftIdByMarketId(marketId)` to show draft origin for curated markets.
- `DraftPublished(draftId, marketId)` event also links them; indexer can use either.
- Not typically a deployment config key for frontend (read from MarketRegistry/DraftBoard).

---

## 8. References

- [MarketDraftBoard.md](MarketDraftBoard.md) — Draft source
- [MarketRegistry.md](MarketRegistry.md) — Market data
- [CREPublishReceiver.md](CREPublishReceiver.md) — Publish flow
- [AppFlow.md](AppFlow.md) — Linking draft to market
