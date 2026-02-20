# Data Structures

**Last updated:** 2026-02-20  
**Context:** [CurrentSmartContract.md](CurrentSmartContract.md) | [Frontend.md](frontend/Frontend.md) | [e2eAvalanceFujiTest.md](../../e2e/e2eAvalanceFujiTest.md)

---

## 1. ShadowTypes (Relayer / ChannelSettlement)

### 1.1 Checkpoint

```solidity
struct Checkpoint {
    uint256 marketId;
    bytes32 sessionId;
    uint64 nonce;
    uint64 validAfter;
    uint64 validBefore;
    uint48 lastTradeAt;
    bytes32 stateHash;
    bytes32 deltasHash;
    bytes32 riskHash;
}
```

| Field | Purpose |
|-------|---------|
| `marketId` | Target market |
| `sessionId` | Session identifier |
| `nonce` | Replay protection; strictly increasing |
| `validAfter` / `validBefore` | Validity window |
| `lastTradeAt` | Must be ≤ market.tradingClose |
| `stateHash` | Off-chain state commitment |
| `deltasHash` | keccak256 of Delta[] |
| `riskHash` | Optional risk data |

### 1.2 Delta

```solidity
struct Delta {
    address user;
    uint32 outcomeIndex;
    int128 sharesDelta;
    int128 cashDelta;
}
```

| Field | Purpose |
|-------|---------|
| `user` | Affected user |
| `outcomeIndex` | Outcome (0 = Yes for binary) |
| `sharesDelta` | Change in ExecutionLedger position |
| `cashDelta` | Change in vault balance (negative = spend) |

---

## 2. MarketDraftBoard.Draft

```solidity
struct Draft {
    bytes32 questionHash;
    bytes32 questionUriHash;
    MarketType marketType;
    bytes32 outcomesHash;
    bytes32 outcomesUriHash;
    bytes32 resolveSpecHash;
    uint48 tradingOpen;
    uint48 tradingClose;
    uint48 resolveTime;
    address settlementAsset;
    uint256 minSeed;
    DraftStatus status;
    address creator;
    uint256 proposedAt;
}
```

URIs are hashes onchain; indexers read full URIs from `DraftProposed` event.

---

## 3. MarketRegistry.Market

```solidity
struct Market {
    address creator;
    uint48 createdAt;
    uint48 expiry;
    uint48 tradingOpen;
    uint48 tradingClose;
    uint48 resolveTime;
    uint48 settledAt;
    bool settled;
    bool frozen;
    uint16 confidence;
    Prediction outcome;    // Yes/No for binary
    string question;
}
```

---

## 4. Enums

### 4.1 MarketType

| Value | Name |
|-------|------|
| 0 | Binary |
| 1 | Categorical |
| 2 | Timeline |

### 4.2 DraftStatus (MarketDraftBoard)

| Value | Name |
|-------|------|
| 0 | Proposed |
| 1 | Claimed |
| 2 | Published |
| 3 | Cancelled |
| 4 | Expired |

### 4.3 Status (MarketRegistry)

| Value | Name |
|-------|------|
| — | Draft (no creator) |
| — | Open |
| — | Frozen |
| — | Resolved |
| — | Closed |

---

## 5. References

- [NitroliteYellowCheckpoint.md](relayer/NitroliteYellowCheckpoint.md)
- [CREReportFormats.md](cre/CREReportFormats.md)
