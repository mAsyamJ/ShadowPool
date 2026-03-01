# RetroPick Protocol Specification (Drop-in Spec)

> Exact semantics for unit economics, multi-outcome markets, and risk budget. Implementation-exact as of current codebase.

---

## Part 1: The Three Core Questions

### 1. Unit Economics: What is a "share"? Redeem 1:1 or variable?

**Answer: 1 share = 1 unit of settlement asset (fixed 1:1 payout)**

| Concept | Definition |
|---------|------------|
| **Share** | An `int256` position stored in `ExecutionLedger` at key `keccak256(user, marketId, outcomeIndex)`. Represents quantity of outcome exposure. |
| **Redemption** | On `MarketRegistry.redeem(marketId)`: `payout = positionOf(user, marketId, winningOutcome).toUint256()`. User receives exactly that many units of the settlement asset (USDC, etc.). |
| **Payout type** | **Fixed 1:1** — winning outcome shares redeem 1:1 for settlement asset. No prorata pool split at resolution. Losing outcome shares are worthless. |
| **Cash vs shares** | `cashDelta` (in `Delta`) updates vault free balance. `sharesDelta` updates `ExecutionLedger`. They are independent; off-chain LS-LMSR (or equivalent) computes both from price/quantity. |

**Source:**
- `MarketRegistry.redeem()`: `payout = shares.toUint256();` then `multiAssetVault.redeemPayout(msg.sender, asset, payout)` or `VAULT.redeemPayout(msg.sender, payout)`.
- `ExecutionLedger.positionOf(user, marketId, outcomeIndex)` returns `int256` shares.

---

### 2. Multi-outcome Markets: Do you allow >2 outcomes?

**Answer: Yes. Binary, Categorical, and Timeline markets are supported.**

| Type | Outcomes | Constraint | Source |
|------|----------|------------|--------|
| **Binary** | 2 (Yes/No) | outcomeIndex ∈ {0, 1} | `MarketType.Binary`, `winningOutcome <= 1` |
| **Categorical** | 2..N | `outcomeIndex < categoricalOutcomes[marketId].length` | `params.outcomes.length >= 2`, `MarketPolicy.maxOutcomes = 64` |
| **Timeline** | 2..N | `outcomeIndex < timelineWindows[marketId].length` | `timelineWindows.length >= 2`, same `maxOutcomes` |

- **Max outcomes (configurable):** `MarketPolicy.maxOutcomes` default 64.
- **Resolution:** `typedOutcomeIndex[marketId]` stores winning index for categorical/timeline.
- **Redeem:** Only shares in winning outcome are redeemable; others are worthless.

**Source:** `MarketFactory`, `MarketRegistry`, `MarketPolicy`.

---

### 3. Risk Budget Model: Is LP vault underwriting bounded per market? Formula today?

**Answer: No on-chain bounded risk. LP vault is unbounded counterparty; solvency is implicit.**

| Aspect | Current behavior |
|--------|------------------|
| **LP vault role** | Per-market `LiquidityVault4626` (ERC-4626) holds underlying asset. When `netTraderDelta > 0` (traders net won), vault pays `payToTradingLedger(to, amount)`. When `netTraderDelta < 0`, vault receives from trading vault. |
| **On-chain bound** | **None.** No cap, no `maxExposurePerMarket`, no risk budget check. |
| **Implicit bound** | `ILiquidityVault4626(lpVault).payToTradingLedger(...)` uses `IERC20.safeTransfer`. If vault lacks assets, transfer reverts → checkpoint finalize fails. So "bound" = vault's asset balance. |
| **riskHash** | Stored in `Checkpoint.riskHash` and `Pending.riskHash` but **never validated on-chain**. Used for off-chain integrity/audit only. |
| **minSeed** | Draft `minSeed` enforces minimum seed deposit at claim; not a risk cap. It seeds initial liquidity. |

**Formula today:** None. Exposure is unbounded by design; relayer/operator are expected to avoid submitting checkpoints that would overdraw the vault. Insolvent checkpoints revert at `safeTransfer`.

**Source:** `ChannelSettlement.finalizeCheckpoint`, `LiquidityVault4626.payToTradingLedger`, `ShadowTypes.Checkpoint.riskHash`.

---

## Part 2: Full Specification Document

### 2.1 Storage Layouts

#### ExecutionLedger

```
_position: mapping(bytes32 => int256)
  key = keccak256(abi.encode(user, marketId, outcomeIndex))
  value = net shares (can go negative conceptually, but contract reverts on negative)
```

#### MarketRegistry

```
markets: mapping(marketId => Market)
  Market { creator, createdAt, expiry, tradingOpen, tradingClose, resolveTime, settledAt, settled, frozen, confidence, outcome, question }

marketTypeById: mapping(marketId => MarketType)  // Binary | Categorical | Timeline
categoricalOutcomes: mapping(marketId => string[])
timelineWindows: mapping(marketId => uint48[])
typedOutcomeIndex: mapping(marketId => uint32)   // winning outcome for categorical/timeline
hasRedeemed: mapping(marketId => mapping(user => bool))
settlementAssetByMarketId: mapping(marketId => address)
liquidityVaultByMarketId: mapping(marketId => address)
usesLpVaultByMarketId: mapping(marketId => bool)
```

#### CollateralVault / MultiAssetVault

- **CollateralVault:** `_freeBalance[user]`, `_lockedBalance[lockKey]` where `lockKey = keccak256(user, marketId, sessionId)`.
- **MultiAssetVault:** `_freeBalance[asset][user]`, `_lockedBalance[lockKey]` where `lockKey = keccak256(asset, user, marketId, sessionId)`.

#### ChannelSettlement.Pending

```
nonce, challengeDeadline, lastTradeAt, stateHash, deltasHash, riskHash, exists
```

---

### 2.2 TokenId / Position Scheme (Current: Ledger-Based, No ERC-1155)

**Current design:** Positions are **not** ERC-1155 tokens. They are stored as `ExecutionLedger._positions[key]` where `key = keccak256(user, marketId, outcomeIndex)`.

**Logical tokenId (if migrating to CTF-style):**
```
tokenId = (marketId << 32) | outcomeIndex
```
- `marketId`: uint256
- `outcomeIndex`: uint32 (fits in lower 32 bits)

---

### 2.3 Function Specs

#### Mint (equivalent: positive sharesDelta)

- **Where:** `ExecutionLedger.applyDeltas` via `ChannelSettlement.finalizeCheckpoint`
- **Semantics:** `_positions[key] += sharesDelta` for each `Delta`
- **Pre:** `next = current + sharesDelta >= 0` (reverts `NegativePosition` otherwise)
- **Pre:** Checkpoint passed challenge window; deltas hash match; market not resolved; `lastTradeAt <= tradingClose`

#### Burn (equivalent: negative sharesDelta)

- Same path; `sharesDelta < 0` reduces position.

#### Merge

- **Not implemented.** No "merge YES+NO for $1" flow. Users hold single-outcome positions; losing shares are worthless at resolution.

#### Redeem

```
MarketRegistry.redeem(marketId)
  PRE: market exists, settled, user has not redeemed
  PRE: positionOf(user, marketId, winningOutcome) > 0
  EFFECT: hasRedeemed[marketId][user] = true
  EFFECT: payout = positionOf(...).toUint256()
  EFFECT: multiAssetVault.redeemPayout(user, asset, payout) OR VAULT.redeemPayout(user, payout)
```

---

### 2.4 Checkpoint Payload

**ShadowTypes.Checkpoint:**
```solidity
uint256 marketId;
bytes32 sessionId;
uint64 nonce;
uint64 validAfter;
uint64 validBefore;
uint48 lastTradeAt;  // must be <= market.tradingClose at finalize
bytes32 stateHash;
bytes32 deltasHash;
bytes32 riskHash;    // NOT validated on-chain
```

**ShadowTypes.Delta:**
```solidity
address user;
uint32 outcomeIndex;
int128 sharesDelta;  // change in ExecutionLedger position
int128 cashDelta;    // change in vault balance (positive = credit, negative = debit)
```

**Validation at submit:**
- `hash(deltas) == cp.deltasHash`
- `validAfter <= block.timestamp <= validBefore` (if nonzero)
- Operator sig valid; every delta user in `users` with valid sig
- Nonce strictly increasing

**Validation at finalize:**
- Pending exists; challenge window elapsed
- Stored deltasHash == recomputed
- Market not resolved; `lastTradeAt <= tradingClose` (if tradingClose set)
- LP vault asset matches settlement asset (if vault bound)

---

### 2.5 Invariants to Enforce (Current + Recommended)

**Currently enforced:**
1. `positionOf >= 0` for all keys
2. Nonce monotonicity
3. Challenge window before finalize
4. `lastTradeAt <= tradingClose`
5. Fee bps cap in FeeManager
6. Outcome index within bounds for typed markets

**Recommended to add:**
1. **Solvency invariant:** Before `payToTradingLedger`, assert `lpVault.asset().balanceOf(lpVault) >= netTraderDelta` (or equivalent). Today this is implicit via `safeTransfer` revert.
2. **riskHash validation:** Optionally verify `riskHash` commits to a valid risk report (e.g., exposure within vault balance) if relayer provides it.
3. **Per-market exposure cap:** If desired, add `maxLpExposurePerMarket` and enforce at finalize.

---

### 2.6 Tests to Add

| Test | Purpose |
|------|---------|
| `redeem_payout_1_to_1` | Assert 10 shares in winning outcome → 10 units payout |
| `categorical_three_outcomes_resolve_second` | Typed market, 3 outcomes, resolve to index 1 |
| `lp_vault_insolvent_reverts` | `netTraderDelta > vault.balance` at finalize → revert |
| `riskHash_stored_but_not_checked` | Document that riskHash is persisted only |
| `maxOutcomes_enforced_at_create` | Creating categorical with 65 outcomes reverts |
| `merge_not_supported` | Document no merge; losing shares worthless |

---

## Part 3: Reference Implementations (Patch-Plan Ready)

> If you paste these functions (or point to them), you can get an exact patch plan (function-by-function pseudocode) and storage additions (new addresses, wiring setters) matching current style (errors, events, modifiers, etc.) for minimal implementation ambiguity.

### Source locations

- **ChannelSettlement:** `src/execution/ChannelSettlement.sol`
- **MarketRegistry:** `src/core/MarketRegistry.sol`
- **MultiAssetVault:** `src/execution/MultiAssetVault.sol`
- **ShadowTypes:** `src/libs/ShadowTypes.sol`

---

### MultiAssetVault — deposit/withdraw APIs (escrow patch-plan ready)

> Paste these and get the exact minimal storage + modifier changes to make MAV a true escrow matching the V3 design.

```solidity
// Storage
mapping(address asset => mapping(address user => uint256)) private _freeBalance;
mapping(bytes32 => uint256) private _lockedBalance;

function deposit(address asset, uint256 amount) external override {
    if (asset == address(0) || amount == 0) revert Errors.InvalidAmount();
    _freeBalance[asset][msg.sender] += amount;
    IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);
    emit Deposited(msg.sender, asset, amount);
}

function withdraw(address asset, uint256 amount) external override {
    if (asset == address(0) || amount == 0) revert Errors.InvalidAmount();
    if (_freeBalance[asset][msg.sender] < amount) revert InsufficientFreeBalance();
    _freeBalance[asset][msg.sender] -= amount;
    IERC20(asset).safeTransfer(msg.sender, amount);
    emit Withdrawn(msg.sender, asset, amount);
}

function freeBalance(address user, address asset) external view override returns (uint256) {
    return _freeBalance[asset][user];
}

function lockedBalance(address user, address asset, uint256 marketId, bytes32 sessionId)
    external
    view
    override
    returns (uint256)
{
    return _lockedBalance[_lockKey(asset, user, marketId, sessionId)];
}

function lock(address user, address asset, uint256 marketId, bytes32 sessionId, uint256 amount) external override {
    if (msg.sender != channelSettlement) revert OnlyChannelSettlement();
    if (asset == address(0) || amount == 0) revert Errors.InvalidAmount();
    if (_freeBalance[asset][user] < amount) revert InsufficientFreeBalance();
    _freeBalance[asset][user] -= amount;
    bytes32 key = _lockKey(asset, user, marketId, sessionId);
    _lockedBalance[key] += amount;
    emit Locked(user, asset, marketId, sessionId, amount);
}

function unlock(address user, address asset, uint256 marketId, bytes32 sessionId, uint256 amount) external override {
    if (msg.sender != channelSettlement) revert OnlyChannelSettlement();
    if (asset == address(0) || amount == 0) revert Errors.InvalidAmount();
    bytes32 key = _lockKey(asset, user, marketId, sessionId);
    if (_lockedBalance[key] < amount) revert InsufficientLockedBalance();
    _lockedBalance[key] -= amount;
    _freeBalance[asset][user] += amount;
    emit Unlocked(user, asset, marketId, sessionId, amount);
}
```

**Lock key:** `keccak256(asset, user, marketId, sessionId)` — see `_lockKey` in full contract.

---

### ChannelSettlement.finalizeCheckpoint

```solidity
function finalizeCheckpoint(
    uint256 marketId,
    bytes32 sessionId,
    ShadowTypes.Delta[] calldata deltas
) external {
    bytes32 k = _key(marketId, sessionId);
    Pending memory p = pendingByKey[k];
    if (!p.exists) revert Errors.NoPending();
    if (block.timestamp < p.challengeDeadline) revert Errors.ChallengeWindow();

    bytes32 dHash = _hashDeltas(deltas);
    if (dHash != p.deltasHash) revert Errors.BadDeltasHash();

    IMarketRegistry mr = marketRegistry;
    bool hasRegistry = address(mr) != address(0);

    // Market lifecycle binding: checkpoint.lastTradeAt must be <= market.tradingClose
    if (hasRegistry) {
        if (mr.status(marketId) == IMarketRegistry.Status.Resolved) {
            revert Errors.MarketAlreadyResolved();
        }
        uint48 tradingClose = mr.getTradingClose(marketId);
        if (tradingClose != 0 && p.lastTradeAt > tradingClose) {
            revert Errors.CheckpointAfterTradingClose();
        }
    }

    LEDGER.applyDeltas(marketId, sessionId, deltas);

    (
        uint256 protocolFee,
        uint256 lpFee,
        uint256 creatorFee,
        int256 netTraderDelta,
        address settlementAsset
    ) = _applyCashDeltasAndFees(marketId, sessionId, deltas);

    address lpVault = hasRegistry ? mr.liquidityVaultByMarketId(marketId) : address(0);

    // Solvency invariant: market flagged as LP must have vault bound
    if (hasRegistry && mr.usesLpVaultByMarketId(marketId) && lpVault == address(0)) {
        revert Errors.LiquidityVaultRequired();
    }

    if (lpVault != address(0)) {
        address vaultAsset = ILiquidityVault4626(lpVault).asset();
        if (vaultAsset != settlementAsset) revert InvalidLiquidityVaultAsset();
    }

    // Net counterparty transfer: LP VAULT <-> TradingCashLedger
    if (lpVault != address(0)) {
        if (netTraderDelta > 0) {
            ILiquidityVault4626(lpVault).payToTradingLedger(
                address(multiAssetVault) != address(0) ? address(multiAssetVault) : address(VAULT),
                netTraderDelta.toUint256()
            );
        } else if (netTraderDelta < 0) {
            if (address(multiAssetVault) != address(0)) {
                multiAssetVault.transferAsset(lpVault, settlementAsset, (-netTraderDelta).toUint256());
            } else {
                VAULT.transferToFeeCollector(lpVault, (-netTraderDelta).toUint256());
            }
        }
    }

    // Fee routing
    if (protocolFee > 0 && address(feePool) != address(0) && feePool.feeCollector() == address(this)) {
        if (address(multiAssetVault) != address(0)) {
            multiAssetVault.transferAsset(address(feePool), settlementAsset, protocolFee);
        } else {
            VAULT.transferToFeeCollector(address(feePool), protocolFee);
        }
        feePool.recordFeeCollected(settlementAsset, protocolFee, marketId, sessionId);
    }
    if (lpFee > 0 && address(multiAssetVault) != address(0)) {
        if (lpVault != address(0) && ILiquidityVault4626(lpVault).totalSupply() > 0) {
            multiAssetVault.transferAsset(lpVault, settlementAsset, lpFee);
        } else if (address(feePool) != address(0) && feePool.treasuryPool() != address(0)) {
            multiAssetVault.transferAsset(feePool.treasuryPool(), settlementAsset, lpFee);
        }
    } else if (lpFee > 0) {
        if (lpVault != address(0) && ILiquidityVault4626(lpVault).totalSupply() > 0) {
            VAULT.transferToFeeCollector(lpVault, lpFee);
        } else if (address(feePool) != address(0) && feePool.treasuryPool() != address(0)) {
            VAULT.transferToFeeCollector(feePool.treasuryPool(), lpFee);
        }
    }
    if (creatorFee > 0 && hasRegistry) {
        address creator = mr.getCreator(marketId);
        if (creator != address(0)) {
            if (address(multiAssetVault) != address(0)) {
                multiAssetVault.transferAsset(creator, settlementAsset, creatorFee);
            } else {
                VAULT.transferToFeeCollector(creator, creatorFee);
            }
        }
    }

    latestNonceByKey[k] = p.nonce;
    delete pendingByKey[k];

    emit CheckpointFinalized(marketId, sessionId, p.nonce);
}
```

---

### ChannelSettlement._applyCashDeltasAndFees (internal)

```solidity
function _applyCashDeltasAndFees(
    uint256 marketId,
    bytes32 sessionId,
    ShadowTypes.Delta[] calldata deltas
)
    internal
    returns (
        uint256 protocolFee,
        uint256 lpFee,
        uint256 creatorFee,
        int256 netTraderDelta,
        address settlementAsset
    )
{
    address mav = address(multiAssetVault);
    IMarketRegistry mr = marketRegistry;
    FeeManager fm = feeManager;

    settlementAsset = mav != address(0) && address(mr) != address(0)
        ? mr.getSettlementAsset(marketId)
        : VAULT.token();

    uint256 deltasLen = deltas.length;
    address[] memory users = new address[](deltasLen);
    int128[] memory cashDeltas = new int128[](deltasLen);
    uint256 count = 0;
    netTraderDelta = 0;

    for (uint256 i = 0; i < deltasLen; i++) {
        int128 delta = deltas[i].cashDelta;
        if (delta == 0) continue;

        int128 netDelta = delta;
        if (address(fm) != address(0) && delta > 0) {
            (uint256 pf, uint256 lf, uint256 cf, int128 nd) = fm.computeSplit(delta);
            protocolFee += pf;
            lpFee += lf;
            creatorFee += cf;
            netDelta = nd;
        }
        netTraderDelta += netDelta;
        users[count] = deltas[i].user;
        cashDeltas[count] = netDelta;
        count++;
    }
    if (count > 0) {
        address[] memory usersTrimmed = new address[](count);
        int128[] memory cashDeltasTrimmed = new int128[](count);
        for (uint256 i = 0; i < count; i++) {
            usersTrimmed[i] = users[i];
            cashDeltasTrimmed[i] = cashDeltas[i];
        }
        if (mav != address(0)) {
            multiAssetVault.applyCashDeltas(settlementAsset, marketId, sessionId, usersTrimmed, cashDeltasTrimmed);
        } else {
            VAULT.applyCashDeltas(marketId, sessionId, usersTrimmed, cashDeltasTrimmed);
        }
    }
}
```

---

### MarketRegistry.redeem

```solidity
function redeem(uint256 marketId) external override returns (uint256 payout) {
    Market memory m = markets[marketId];
    if (m.creator == address(0)) revert MarketDoesNotExist();
    if (!m.settled) revert MarketNotSettled();
    if (hasRedeemed[marketId][msg.sender]) revert AlreadyRedeemed();

    uint32 winningOutcome;
    if (marketTypeById[marketId] == MarketType.Binary) {
        winningOutcome = uint32(uint8(m.outcome));
    } else {
        winningOutcome = typedOutcomeIndex[marketId];
    }

    int256 shares = LEDGER.positionOf(msg.sender, marketId, winningOutcome);
    if (shares <= 0) revert NothingToRedeem();

    hasRedeemed[marketId][msg.sender] = true;
    payout = shares.toUint256();
    address asset = this.getSettlementAsset(marketId);
    if (address(multiAssetVault) != address(0)) {
        multiAssetVault.redeemPayout(msg.sender, asset, payout);
    } else {
        VAULT.redeemPayout(msg.sender, payout);
    }
    emit Redeemed(marketId, msg.sender, payout);
}
```

---

## Summary Table

| Question | Answer |
|----------|--------|
| 1 share redeems to | 1 unit settlement asset (fixed 1:1) |
| >2 outcomes? | Yes (Binary, Categorical, Timeline; maxOutcomes=64) |
| LP risk bound? | No on-chain formula; implicit = vault balance |

---

## Part 4: Implementation Diff Checklist (ERC-1155 / OZ v5)

> Tight checklist for OutcomeToken1155 transfer-lock and minimal MarketRegistry interface. OZ v5 uses `_update` (no `_beforeTokenTransfer`).

### 4.1 OutcomeToken1155 — `_update` Override (OZ v5)

**Exact signature:**

```solidity
function _update(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory values
) internal virtual override
```

**Logic:**
- If `from != address(0) && to != address(0)` → transfer (not mint/burn).
- For each `ids[i]`:
  - Decode: `marketId = ids.unsafeMemoryAccess(i) >> 32`, `outcomeIndex = uint32(ids.unsafeMemoryAccess(i))`
  - Require: `IMarketRegistry(marketRegistry).status(marketId) == IMarketRegistry.Status.Resolved`
  - Else revert `Errors.TransferLocked()`
- Call `super._update(from, to, ids, values)`

**Dependencies:** `IMarketRegistry.status(marketId)`.

---

### 4.2 IMarketRegistry — Minimal Interface for OutcomeToken1155

| Method | Signature | Purpose |
|--------|-----------|---------|
| `status` | `function status(uint256 marketId) external view returns (Status)` | Transfer lock: allow transfers only when `Resolved` |
| `numOutcomes` | `function numOutcomes(uint256 marketId) external view returns (uint32)` | Optional: validate `outcomeIndex < numOutcomes` in tokenId |

**`numOutcomes` implementation (MarketRegistry):**
- `Binary` → `2`
- `Categorical` → `uint32(categoricalOutcomes[marketId].length)`
- `Timeline` → `uint32(timelineWindows[marketId].length)`

**Note:** Current `OutcomeToken1155` only uses `status`. Add `numOutcomes` if you want outcome-index bounds checks in `_update`.

---

### 4.3 Checklist Summary

| # | Task | Status |
|---|------|--------|
| 1 | Override `_update(address from, address to, uint256[] memory ids, uint256[] memory values)` in OutcomeToken1155 | Done (current code) |
| 2 | Decode `marketId = id >> 32` per tokenId | Done |
| 3 | Query `mr.status(marketId)`; revert if not Resolved for user→user transfers | Done |
| 4 | Add `numOutcomes(uint256 marketId)` to IMarketRegistry | Pending |
| 5 | Implement `numOutcomes` in MarketRegistry (Binary→2, Categorical→length, Timeline→length) | Pending |
| 6 | (Optional) In `_update`, add `outcomeIndex < mr.numOutcomes(marketId)` check | Pending |

---

## Part 5: Escrow-Safe Implementation Diff Checklist

> Exact Solidity-level patches for escrow safety (reserve-on-submit, release-on-finalize). See `.docs/escrowPlan.md` for full design rationale.

### 5.1 Planned Code Diffs

| # | Patch | Scope |
|---|-------|-------|
| 1 | **MultiAssetVault** | Storage + reserve/release + withdraw checks |
| 2 | **ChannelSettlement.submitCheckpoint** | Reserve compute + store in Pending |
| 3 | **ChannelSettlement** replace-pending logic | Release old reserves when new checkpoint replaces pending |
| 4 | **cancelPendingCheckpoint()** | Escape hatch: release reserves + delete pending after timeout |

### 5.2 Inputs Required

To produce patches matching exact Errors/events style and storage patterns:

- `submitCheckpoint` / `submitCheckpointFromPayload` implementation
- `Pending` struct definition
