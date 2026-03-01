# ABI Reference (Frontend)

**Last updated:** 2026-03-01  
**ABI location:** `docs/abi/*.json`  
**Context:** [DeploymentConfig.md](DeploymentConfig.md) | Per-contract docs in this folder

---

## 1. Overview

This document provides a condensed ABI reference for frontend integration. For full method signatures and structs, use the JSON files directly. For integration details, see the per-contract docs.

---

## 2. Contract Summary

| Contract | ABI File | Key Reads | Key Writes | Doc |
|----------|-----------|-----------|------------|-----|
| MarketRegistry | MarketRegistry.json | getMarket, status, marketType, typedOutcomeIndex, liquidityVaultByMarketId, getSettlementAsset | redeem, freeze | [MarketRegistry.md](MarketRegistry.md) |
| MarketDraftBoard | MarketDraftBoard.json | draftCount, getDraftIdAt, getDraft, getStatus | — | [MarketDraftBoard.md](MarketDraftBoard.md) |
| DraftClaimManager | DraftClaimManager.json | nonces, getClaimer, getLiquidityVault, seedSharesLocked, seedUnlockTime | claimAndSeed, unlockSeedShares | [DraftClaimManager.md](DraftClaimManager.md) |
| OutcomeToken1155 | OutcomeToken1155.json | balanceOf, balanceOfBatch, id | safeTransferFrom, setApprovalForAll | [OutcomeToken1155.md](OutcomeToken1155.md) |
| ChannelSettlement | ChannelSettlement.json | latestNonce | — (relayer/CRE-driven) | [ChannelSettlement.md](ChannelSettlement.md) |
| CollateralVault | CollateralVault.json | freeBalance, reservedBalance, token | deposit, withdraw | [CollateralVault.md](CollateralVault.md) |
| MultiAssetVault | MultiAssetVault.json | freeBalance, reservedBalance | deposit, withdraw | [MultiAssetVault.md](MultiAssetVault.md) |
| LiquidityVaultFactory | LiquidityVaultFactory.json | getVault | — | [LiquidityVaultFactory.md](LiquidityVaultFactory.md) |
| MarketRiskManager | MarketRiskManager.json | maxLpPayout, reservedLpPayout | — | [MarketRiskManager.md](MarketRiskManager.md) |
| Faucet | Faucet.json | canClaim, tokenConfig, lastClaimAt | claim | [Faucet.md](Faucet.md) |
| FeeManager | FeeManager.json | computeSplit, protocolFeeBps | — | [FeeManager.md](FeeManager.md) |
| FeePool | FeePool.json | feeCollector | — | [FeePool.md](FeePool.md) |
| TreasuryPool | TreasuryPool.json | — | — | [TreasuryPool.md](TreasuryPool.md) |

---

## 3. Key Method Signatures (Copy-Paste)

### MarketRegistry

```
getMarket(uint256 marketId) → (creator, createdAt, expiry, tradingOpen, tradingClose, resolveTime, settledAt, settled, frozen, confidence, outcome, question)
status(uint256 marketId) → uint8
marketType(uint256 marketId) → uint8
typedOutcomeIndex(uint256 marketId) → uint32
liquidityVaultByMarketId(uint256 marketId) → address
getSettlementAsset(uint256 marketId) → address
redeem(uint256 marketId)
```

### MarketDraftBoard

```
draftCount() → uint256
getDraftIdAt(uint256 index) → bytes32
getDraft(bytes32 draftId) → Draft
getStatus(bytes32 draftId) → uint8
```

### DraftClaimManager

```
nonces(address user) → uint256
claimAndSeed(bytes32 draftId, address asset, uint256 seedAmount, uint256 deadline, bytes sig)
unlockSeedShares(bytes32 draftId)
getLiquidityVault(bytes32 draftId) → address
getClaimer(bytes32 draftId) → address
seedSharesLocked(bytes32 draftId) → uint256
seedUnlockTime(bytes32 draftId) → uint48
digestClaimAndSeed(bytes32 draftId, address asset, uint256 seedAmount, uint256 deadline, address signer) → bytes32
```

### OutcomeToken1155

```
balanceOf(address account, uint256 id) → uint256
balanceOfBatch(address[] accounts, uint256[] ids) → uint256[]
id(uint256 marketId, uint32 outcomeIndex) → uint256
safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes data)
setApprovalForAll(address operator, bool approved)
```

### CollateralVault / MultiAssetVault

```
freeBalance(address user) → uint256   // CollateralVault
freeBalance(address user, address asset) → uint256  // MultiAssetVault
reservedBalance(address user) → uint256  // CollateralVault
reservedBalance(address user, address asset) → uint256  // MultiAssetVault
deposit(uint256 amount)  // or deposit(address asset, uint256 amount) for MAV
withdraw(uint256 amount, address to)  // or withdraw(address asset, uint256 amount, address to)
```

### LiquidityVault4626 (ERC-4626)

```
balanceOf(address account) → uint256
totalAssets() → uint256
asset() → address
deposit(uint256 assets, address receiver)
withdraw(uint256 assets, address receiver, address owner)
convertToShares(uint256 assets) → uint256
convertToAssets(uint256 shares) → uint256
```

### ChannelSettlement

```
latestNonce(uint256 marketId, bytes32 sessionId) → uint64
```

### Faucet

```
canClaim(address user, address token) → bool
claim(address token)
tokenConfig(address token) → (bool enabled, uint96 amountPerClaim, uint32 cooldownSecs)
lastClaimAt(address user, address token) → uint256
```

### MarketRiskManager

```
maxLpPayout(uint256 marketId) → uint256
reservedLpPayout(uint256 marketId) → uint256
```

---

## 4. Key Events (Indexed Params)

| Contract | Event | Indexed | Use |
|----------|-------|---------|-----|
| MarketRegistry | MarketCreated | marketId | Market list index |
| MarketRegistry | MarketResolved | marketId | Enable redeem |
| MarketRegistry | Redeemed | marketId, user | Track hasRedeemed |
| MarketDraftBoard | DraftProposed | draftId | New draft; questionURI, outcomesURI |
| MarketDraftBoard | DraftPublished | draftId, marketId | Draft → market link |
| DraftClaimManager | DraftClaimedAndSeeded | draftId, claimer | Seeded claim |
| DraftClaimManager | SeedSharesUnlocked | draftId, claimer | Unlock success |
| ChannelSettlement | CheckpointSubmitted | marketId, sessionId | Pending checkpoint |
| ChannelSettlement | CheckpointFinalized | marketId, sessionId | Refresh positions |
| OutcomeToken1155 | TransferSingle | operator, from, to, id | Position change |
| Faucet | Claimed | user, token | Refresh balance |

---

## 5. Key Errors (Revert Mapping)

See [ErrorsReference.md](ErrorsReference.md) for full error → user message mapping.

---

## 6. ABI Loading (viem / ethers)

```ts
// viem
import MarketRegistryAbi from './docs/abi/MarketRegistry.json';
const contract = getContract({ address: MARKET_REGISTRY, abi: MarketRegistryAbi });

// ethers v6
import MarketRegistryAbi from './docs/abi/MarketRegistry.json';
const contract = new ethers.Contract(MARKET_REGISTRY, MarketRegistryAbi, signer);
```

---

## 7. References

- [DeploymentConfig.md](DeploymentConfig.md) — Contract addresses
- Per-contract docs in this folder — Full integration details
- [DataStructures.md](../DataStructures.md) — Checkpoint, Delta, Draft, Market structs
