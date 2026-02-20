# MarketDraftBoard – Frontend Integration

Last updated: 2026-02-20  
ABI: `MarketDraftBoard.json`  
Context: [Frontend.md](Frontend.md) | [CurrentSmartContract.md](../CurrentSmartContract.md)

---

## 1. Contract Purpose

`MarketDraftBoard` stores AI-proposed market drafts. It is the canonical source for draft discovery, status, and lifecycle. AI oracle proposes drafts; creators claim via `DraftClaimManager`; `MarketFactory` marks published.

---

## 2. Frontend Relevance

| Feature | User Role | Use Case |
|--------|-----------|----------|
| Draft discovery | All, Curator | Paginated draft list with status badges |
| Draft card | All | Question, market type, timing, `minSeed`, `settlementAsset` |
| Status badges | All | Proposed (0), Claimed (1), Published (2), Cancelled (3), Expired (4) |

---

## 3. Read Methods (Frontend)

| Method | Params | Returns | Use Case |
|--------|--------|---------|----------|
| `getDraft` | `bytes32 draftId` | `Draft` struct | Draft detail for card/modal |
| `getStatus` | `bytes32 draftId` | `uint8` (DraftStatus) | Status badge |
| `draftCount` | — | `uint256` | Total drafts, pagination |
| `getDraftIdAt` | `uint256 index` | `bytes32 draftId` | Paginate draft IDs |
| `drafts` | `bytes32 draftId` | `Draft` struct | Alternative to `getDraft` |

**Draft struct (getDraft)**: `questionHash`, `questionUriHash`, `marketType`, `outcomesHash`, `outcomesUriHash`, `resolveSpecHash`, `tradingOpen`, `tradingClose`, `resolveTime`, `settlementAsset`, `minSeed`, `status`, `creator`, `proposedAt`

**Note**: URIs are hashes onchain. Indexers should read full `questionURI` and `outcomesURI` from `DraftProposed` event for display.

---

## 4. Write Methods (Frontend)

Frontend does not call write methods on `MarketDraftBoard` directly. `proposeDraft`, `setClaimed`, `markPublished`, `cancelDraft`, `expireDraft` are called by AI oracle, `DraftClaimManager`, or `MarketFactory`.

---

## 5. Events

| Event | Indexed Params | Use Case |
|-------|----------------|----------|
| `DraftProposed` | `draftId` | New draft for list; index `questionURI`, `outcomesURI` for display |
| `DraftClaimed` | `draftId`, `claimer` | Draft claimed (legacy path) |
| `DraftPublished` | `draftId`, `marketId` | Draft went live; update status, show market link |
| `DraftCancelled` | `draftId` | Status update |
| `DraftExpired` | `draftId` | Status update |
| `DraftClaimManagerUpdated` | `previous`, `current` | Admin change (rare) |

---

## 6. Errors

| Error | User-Friendly Message |
|-------|------------------------|
| `DraftNotProposed` | This draft is no longer available to claim |
| `DraftDoesNotExist` | Draft not found |
| `DraftAlreadyCancelled` | Draft was cancelled |
| `DraftAlreadyExpired` | Draft has expired |
| `DraftAlreadyPublished` | Draft already published |
| `DraftNotClaimed` | Draft must be claimed first |
| `InvalidOutcomeCount` | Invalid outcome count |
| `InvalidTimelineWindows` | Invalid timeline windows |
| `AccessControlUnauthorizedAccount` | Unauthorized |
| `OwnableUnauthorizedAccount` | Unauthorized |

---

## 7. Integration Notes

- **Pagination**: `draftCount()` and `getDraftIdAt(i)` for indices 0 to draftCount-1.
- **URIs**: `getDraft` returns `questionUriHash`, `outcomesUriHash`. Full URIs in `DraftProposed` event (indexers).
- **Filter**: By `status` (Proposed, Claimed, Published, Cancelled, Expired).
- **MarketType**: Binary (0), Categorical (1), Timeline (2).
- **Deployment config key**: `MarketDraftBoard`

---

## 8. References

- [DraftClaimManager.md](DraftClaimManager.md) — Claim flow
- [MarketFactory.md](MarketFactory.md) — Publish, `draftIdByMarketId`
- [AppFlow.md](AppFlow.md) — Curated path flow
