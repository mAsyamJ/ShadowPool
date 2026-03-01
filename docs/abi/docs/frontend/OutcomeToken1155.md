# OutcomeToken1155 – Frontend Integration (V3)

**Last updated:** 2026-03-01  
**ABI:** `OutcomeToken1155.json`  
**Context:** [Frontend.md](Frontend.md) | [CurrentSmartContract.md](../CurrentSmartContract.md)

---

## 1. Contract Purpose

`OutcomeToken1155` is the **V3 canonical store for outcome positions**. It is an ERC-1155 token where each token ID represents a (market, outcome) pair. Positions are minted/burned by `ChannelSettlement` when checkpoints are finalized. Users hold outcome shares as ERC-1155 balances. Transfer is **locked** until the market is resolved; after resolution, transfers are allowed (Polymarket-like composability).

**Replaces:** `ExecutionLedger.positionOf` for V3 deployments.

---

## 2. Frontend Relevance

| Feature | User Role | Use Case |
|---------|-----------|----------|
| Position display | Trader | Show shares per outcome per market |
| Redeem eligibility | Trader | Check winning outcome balance before `MarketRegistry.redeem` |
| Portfolio | Trader | Aggregate positions across markets |
| Transfer (post-resolve) | Trader | Optional: transfer winning tokens to others |

---

## 3. Token ID Derivation

Token ID = `id(marketId, outcomeIndex)` — a pure function on the contract:

```
tokenId = (marketId << 32) | outcomeIndex
```

**Frontend:** Use `outcomeToken.id(marketId, outcomeIndex)` or compute as above.

| outcomeIndex | Binary market | Description |
|--------------|---------------|-------------|
| 0 | Yes | Outcome 0 |
| 1 | No | Outcome 1 |
| 0, 1, 2, ... | Categorical | Outcome indices |
| 0, 1, 2, ... | Timeline | Window indices |

---

## 4. Read Methods (Frontend)

| Method | Params | Returns | Use Case |
|--------|--------|---------|----------|
| `balanceOf` | `address account`, `uint256 id` | `uint256` | Shares for (account, tokenId) |
| `balanceOfBatch` | `address[] accounts`, `uint256[] ids` | `uint256[]` | Batch position lookup |
| `id` | `uint256 marketId`, `uint32 outcomeIndex` | `uint256` | Token ID for (market, outcome) |
| `channelSettlement` | — | `address` | Mint/burn authority |
| `marketRegistry` | — | `address` | Burn-for-redeem authority |

**Example:**

```ts
const tokenId = await outcomeToken.read.id([marketId, outcomeIndex]);
const balance = await outcomeToken.read.balanceOf([userAddress, tokenId]);
```

---

## 5. Write Methods (Frontend)

| Method | Params | When Called |
|--------|--------|--------------|
| `safeTransferFrom` | `from`, `to`, `id`, `amount`, `data` | User transfers (only when market resolved) |
| `safeBatchTransferFrom` | `from`, `to`, `ids`, `amounts`, `data` | Batch transfer (only when markets resolved) |
| `setApprovalForAll` | `operator`, `approved` | Approve operator (e.g. marketplace) |

**mint / burn / burnForRedeem:** Only callable by ChannelSettlement or MarketRegistry; frontend does not call these.

---

## 6. Transfer Lock

- **Pre-resolution:** User-to-user transfers revert with `TransferLocked`
- **Post-resolution:** `marketRegistry.status(marketId) == Resolved` — transfers allowed
- **Mint/burn:** Always allowed from ChannelSettlement

---

## 7. Redeem Flow

1. Market resolved; winning outcome = `typedOutcomeIndex(marketId)` (or `market.outcome` for binary)
2. Frontend checks `balanceOf(user, id(marketId, winningOutcome)) > 0`
3. User calls `MarketRegistry.redeem(marketId)`
4. Registry calls `outcomeToken.burnForRedeem(user, marketId, winningOutcome, shares)` and pays from vault
5. One-shot per (marketId, user); track `Redeemed` events for `hasRedeemed`

---

## 8. Events

| Event | Indexed | Use Case |
|-------|---------|----------|
| `TransferSingle` | operator, from, to, id | Position mint/burn/transfer |
| `TransferBatch` | operator, from, to | Batch transfer |
| `ApprovalForAll` | account, operator | Approval change |

---

## 9. Errors

| Error | User Message |
|-------|--------------|
| `TransferLocked` | Cannot transfer outcome tokens until market is resolved |
| `ERC1155InsufficientBalance` | Insufficient balance |
| `ERC1155InvalidReceiver` | Invalid receiver |
| `ERC1155MissingApprovalForAll` | Operator not approved |

---

## 10. Integration Notes

- **Deployment config key:** `OutcomeToken1155` or `OUTCOME_TOKEN`
- **Position display:** For each market, iterate outcomes (0 to N-1); call `balanceOf(user, id(marketId, outcomeIndex))`
- **Redeem check:** `balanceOf(user, id(marketId, winningOutcome)) > 0` and not yet redeemed (via `Redeemed` events)
- After `CheckpointFinalized`, refresh affected `balanceOf` calls

---

## 11. References

- [MarketRegistry.md](MarketRegistry.md) — Redeem flow, winning outcome
- [ChannelSettlement.md](ChannelSettlement.md) — Mint/burn on checkpoint finalize
- [ExecutionLedger.md](ExecutionLedger.md) — Deprecated; V3 uses OutcomeToken1155
