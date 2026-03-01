Great — this MAV is a **clean starting point**, but as-is it is **NOT a safe escrow** for a prediction market with:

* off-chain execution,
* checkpoint settlement,
* LP underwriting with risk reservation,
* and “users can withdraw anytime”.

Right now, MAV only enforces:

✅ “you can’t withdraw more than freeBalance”
✅ “ChannelSettlement can lock/unlock”

But it **does not** enforce the thing escrow *must* enforce:

> **Users cannot withdraw collateral that backs open positions / pending checkpoints / obligations.**

Because your trading engine is off-chain, the protocol must harden the custody layer so no one can “withdraw mid-flight”.

Below is the **best solution** that stays minimal, works with your current architecture, and is audit-friendly.

---

# 0) Threat model (what can go wrong today)

### Attack / failure A — “Withdraw right before a checkpoint finalizes”

* User trades off-chain, signs checkpoint.
* Before checkpoint is finalized on-chain, user calls `withdraw()` and drains freeBalance.
* If your settlement expects to debit them (`cashDelta < 0`), MAV applyCashDeltas will revert or create insolvency.

Even if it “just reverts,” it becomes a **grief vector**: users can sabotage settlement by withdrawing at the wrong time.

### Attack / failure B — “Open exposure without locking collateral”

Your MAV lock is per `(marketId, sessionId)` but your deltas don’t necessarily lock users at trade time unless the relayer/CS explicitly calls `lock()`.

If you don’t lock as you trade, then **freeBalance is not meaningful collateral**.

### Attack / failure C — LP reserved capital is not protected

Your `MarketRiskManager` will reserve payout, but if LP vault can still withdraw underlying, reservation doesn’t actually protect funds.

(That’s the “phase 2” vault change; I’ll integrate it cleanly.)

---

# 1) The safest minimal escrow model for RetroPick

You want a model that is:

* **simple** (auditable),
* **compatible** with checkpoint settlement,
* **doesn’t require per-trade on-chain tx**,
* **prevents withdraw griefing**.

## Core idea: add `reservedBalance` at the vault layer

MAV becomes 3-bucket accounting:

1. `freeBalance` — withdrawable *only if not reserved*
2. `reservedBalance` — non-withdrawable backing obligations (positions/pending checkpoints)
3. `lockedBalance` — specifically locked to `(marketId, sessionId)` if you need it

Invariants:

* `withdraw` must enforce:
  **amount ≤ freeBalance − reservedBalance**
* `ChannelSettlement` can increase/decrease reserved as exposure changes.

This is the biggest upgrade for safety.

---

# 2) Minimal storage additions (MAV)

Add:

```solidity
mapping(address asset => mapping(address user => uint256)) private _reservedBalance;
```

and views:

```solidity
function reservedBalance(address user, address asset) external view returns (uint256);
function availableBalance(address user, address asset) external view returns (uint256); // free - reserved
```

---

# 3) Minimal API additions (MAV)

Add these functions, callable only by `channelSettlement`:

```solidity
function reserve(address user, address asset, uint256 amount) external;
function release(address user, address asset, uint256 amount) external;
```

Rules:

* `reserve`: moves funds from `free → reserved` (still within MAV custody)
* `release`: moves funds from `reserved → free`

### Why not reuse `lock`?

Because your `lock` key includes `(marketId, sessionId)` which is too granular for “global withdraw blocking”. You’ll still keep lock for “session-level” semantics, but reservation is the correct tool for **escrow**.

---

# 4) Patch plan: modify `withdraw` (critical)

Current:

```solidity
if (_freeBalance[asset][msg.sender] < amount) revert InsufficientFreeBalance();
```

Replace with:

```solidity
uint256 free = _freeBalance[asset][msg.sender];
uint256 reserved = _reservedBalance[asset][msg.sender];
if (free < reserved + amount) revert InsufficientAvailableBalance();
```

This single change turns MAV from “balance tracker” into “escrow”.

---

# 5) How do you set reserved balances? (where many systems fail)

You need a consistent policy. The best one for RetroPick v3 is:

## Reserve based on worst-case debit *before* the checkpoint finalizes

Because trades are off-chain, the only on-chain moment you can safely update is:

* on checkpoint submit (pending)
* or checkpoint finalize

### The best solution:

**Reserve on submit, settle on finalize**

#### On `submitCheckpoint(...)` (or `submitCheckpointFromPayload`)

* Compute each user’s **max possible debit** implied by the checkpoint (or use a relayer-provided per-user “required reserve” array committed in `stateHash`).
* Call `MAV.reserve(user, asset, reserveDelta)`.

Then, when finalize happens:

* you apply cash deltas and then `release` the reserved that is no longer needed.

But: your `submitCheckpoint` currently stores pending and doesn’t apply deltas.

So we need one new data structure:

### Pending reserve snapshot

Store in `ChannelSettlement.Pending`:

* `bytes32 reserveHash` (commitment to per-user reserve requirements)
* or store `uint256 totalReserved` + per-user mapping (too expensive on-chain)

**Minimal**: use a hash and require users sign it (already signing checkpoint).

Then MAV doesn’t need to know the list until finalization; it just needs reserve applied early.

---

## If you don’t want reserve on submit (simpler)

Then at minimum:

* enforce that relayer calls `lock()` (session lock) *as users trade* off-chain.
  But that implies on-chain tx per trade (not acceptable).

So: **reserve-on-submit is the correct design**.

---

# 6) Concrete “Escrow-safe” flow (with your architecture)

### A) User deposit

* user deposits into MAV freeBalance

### B) Off-chain trading

* no on-chain calls

### C) Checkpoint submission (CRE → ChannelSettlement.submitCheckpointFromPayload)

New behavior:

1. validate checkpoint signatures (already)
2. decode `Reserve[]` array or `reserveHash + reserveProof` (choose one)
3. call `MAV.reserve(user, asset, amount)` for each user in reserve list
4. store pending

### D) Challenge window

* users cannot withdraw reserved funds, so settlement cannot be griefed.

### E) Finalize checkpoint

* apply ERC-1155 mint/burn
* apply cash deltas (net)
* release reservation amounts that are no longer needed

---

# 7) “Most great solution” for reserves: what exactly do we reserve?

Since you use LS-LMSR (or equivalent), the clean reserve definition is:

> **Reserve must cover the maximum possible negative cashDelta for the user between now and finalize.**

In a checkpoint, cashDelta is already computed. The safest approach is:

### Reserve exact required debit per user from the checkpoint

For each user:

* compute `debit = max(0, -netCashDeltaUser)` (after fees)
* reserve `debit`

Because if user owes money, finalize will debit them.

This ensures the debit cannot fail due to withdraw.

**If cashDeltaUser is positive**, they don’t need reserve.

This is minimal and aligns with your current delta model.

---

# 8) How to implement reserve list with minimal gas

Your `Delta[]` already includes `user` and `cashDelta`.

So you can compute reserves inside `ChannelSettlement.submitCheckpoint...` without extra data:

* iterate deltas
* aggregate per user: `netCashDeltaUser += netDelta`
* reserve `max(0, -netCashDeltaUser)` for each user

But you need a per-user accumulator map, which is expensive in memory if done naively.

### Efficient approach:

Because `MAX_DELTAS=256`, you can do:

* collect unique users in memory arrays (O(n²) worst-case but n=256 is fine)
* aggregate per user

Then reserve each negative user amount.

**This is totally doable** at 256 scale and is clean.

---

# 9) LP safety integration (RiskManager + Vault withdrawals)

You already decided: “risk reservation”.

That protects LP payout from runaway underwriting, but you must ensure LP cannot withdraw reserved funds.

### Phase 1 (now): enforce cap only

* `MarketRiskManager.reserveLpPayout` prevents over-underwriting.
* Still possible LP withdraws and breaks solvency later.

### Phase 2 (production): enforce withdraw limits in `LiquidityVault4626`

Add:

* `address riskManager`
* `totalReserved()` getter on riskManager (global sum across markets for this vault asset or per vault)
* in vault `withdraw/redeem`: require `amount <= totalAssets - reserved`

This makes underwriting real.

---

# 10) Exact diff summary (what to change)

## MultiAssetVault changes (minimal)

### Storage

* add `_reservedBalance`

### Modify `withdraw`

* enforce `free - reserved`

### Add functions (onlyChannelSettlement)

* `reserve(user, asset, amount)`
* `release(user, asset, amount)`

### Add events

* `Reserved(user, asset, amount)`
* `Released(user, asset, amount)`

---

## ChannelSettlement changes (escrow-safe)

### On submit checkpoint

* compute per-user required reserves from deltas (negative cash delta)
* call `MAV.reserve` for each user with required debit
* store pending

### On finalize checkpoint

* apply cash deltas
* release the reserved amounts for users (either fully, or re-calc new required reserve and keep remainder)

Simplest release strategy:

* reserve applies only for the checkpoint window
* after finalize, release all reserves created for that checkpoint

To do that you must store `reservedTotalByKey` or `reservedHash` + replay the list at finalize.

Given max 256, easiest:

* store `bytes32 reserveHash`
* but you still need exact list at finalize to release.
  So simplest: store `Reserve[]` onchain in pending (but dynamic arrays in storage are expensive).

**Better compromise (still minimal):**

* store `reservedAmountByKey[lockKey]` in MAV using your existing lockKey!
* i.e., reuse `_lockedBalance[key]` as the reserved bucket for checkpoint window.

This is actually the best minimal patch:

### New interpretation:

* `lock()` becomes “reserve for checkpoint window”
* `withdraw()` must also subtract `sumLockedAcrossAllSessions` which is not possible.

So no: keep separate reserved bucket.

Thus: in practice you need a release list.

Given scale 256, easiest safe choice:

* **reserve and release happen in finalize only** → doesn’t block withdraw during challenge window (not safe).

So we do need reserve on submit and release on finalize with a list.

### Best minimal implementation:

Store in `ChannelSettlement.Pending`:

* `address[] reserveUsers`
* `uint256[] reserveAmounts`

Yes this uses storage arrays, but bounded by 256 and only per pending checkpoint. It’s acceptable.

---

# 11) Recommended final choice (safe + implementable + minimal)

✅ Add `_reservedBalance` in MAV
✅ On checkpoint **submit**, compute required reserves and store them in Pending arrays
✅ Call `reserve` for each
✅ On checkpoint **finalize**, release exactly those reserves (or recompute and adjust)

This gives you a true escrow.

---

# 12) New edge cases & how this design handles them

### If checkpoint is challenged and replaced

* must release old reserves before reserving new ones OR adjust (delta reserve).
  Solution:
* when a pending is replaced, first `release` old pending reserves, then reserve new ones.

### If checkpoint expires / is canceled / never finalized

You need a way to reclaim reserves:

* add `cancelPendingCheckpoint` callable by anyone after a long timeout, which releases reserves and deletes pending.

This is essential in production.

---

# 13) Quick checklist: “RetroPick Escrow Safe = YES”

RetroPick is escrow-safe when:

* [x] user cannot withdraw collateral backing pending deltas
* [x] checkpoint cannot be griefed via withdraw
* [x] LP underwriting bounded (risk cap)
* [x] LP cannot withdraw reserved underwriting (phase 2)

---

## If you want, I can now write the exact code diff (Solidity-level)

To be precise, I’d produce:

1. `MultiAssetVault` patch code (storage + reserve/release + withdraw checks)
2. `ChannelSettlement.submitCheckpoint` patch (reserve compute + store in pending)
3. `ChannelSettlement` replace-pending logic to release old reserves
4. `cancelPendingCheckpoint()` escape hatch

If you paste your `submitCheckpoint` / `submitCheckpointFromPayload` and `Pending` struct, I’ll make it match your exact Errors/events style and your existing storage mapping patterns.

Got it. You **don’t need to paste more code** for me to deliver something useful right now — I can give you an **escrow-safe patch spec + Solidity diff templates** that you can drop into your repo with minimal adaptation.

I’ll structure this exactly like an engineering checklist + patch plan, matching your current style (Errors, events, bounded arrays, `Pending` by key, challenge window, replacement logic).

Below is what you need to implement **reserve-on-submit, release-on-finalize**, plus safe replacement and a cancel escape hatch.

---

# RetroPick Escrow-Safe Patches

## Reserve-on-submit, release-on-finalize (MultiAssetVault + ChannelSettlement)

### Objectives (what “escrow safe” means)

A market is escrow-safe when:

1. **No user can withdraw collateral needed to settle a signed checkpoint** during challenge window.
2. **Checkpoint replacement** does not trap funds in reserved state.
3. **Stuck pending checkpoints** can be canceled and reserves released after a timeout.

---

# Patch 1 — MultiAssetVault: add reserved balances + withdraw checks

## 1.1 New storage

Add below `_freeBalance`:

```solidity
mapping(address asset => mapping(address user => uint256)) private _reservedBalance;
```

## 1.2 New errors

Add (or map to your existing Errors library patterns):

```solidity
error InsufficientAvailableBalance();
error InsufficientReservedBalance();
```

(If you already centralize in `Errors.sol`, place there.)

## 1.3 New events

```solidity
event Reserved(address indexed user, address indexed asset, uint256 amount);
event Released(address indexed user, address indexed asset, uint256 amount);
```

## 1.4 New views

```solidity
function reservedBalance(address user, address asset) external view returns (uint256) {
    return _reservedBalance[asset][user];
}

function availableBalance(address user, address asset) external view returns (uint256) {
    uint256 free = _freeBalance[asset][user];
    uint256 res = _reservedBalance[asset][user];
    return free > res ? free - res : 0;
}
```

## 1.5 Patch withdraw

Replace:

```solidity
if (_freeBalance[asset][msg.sender] < amount) revert InsufficientFreeBalance();
_freeBalance[asset][msg.sender] -= amount;
```

with:

```solidity
uint256 free = _freeBalance[asset][msg.sender];
uint256 res = _reservedBalance[asset][msg.sender];
if (free < res + amount) revert InsufficientAvailableBalance();
_freeBalance[asset][msg.sender] = free - amount;
```

✅ This single rule blocks “withdraw-to-grief-checkpoint”.

## 1.6 Add reserve/release (onlyChannelSettlement)

```solidity
function reserve(address user, address asset, uint256 amount) external {
    if (msg.sender != channelSettlement) revert OnlyChannelSettlement();
    if (asset == address(0) || amount == 0) revert Errors.InvalidAmount();

    uint256 free = _freeBalance[asset][user];
    uint256 res = _reservedBalance[asset][user];
    // reserve consumes from free (but remains in vault custody)
    if (free < res + amount) revert InsufficientAvailableBalance();

    _reservedBalance[asset][user] = res + amount;
    emit Reserved(user, asset, amount);
}

function release(address user, address asset, uint256 amount) external {
    if (msg.sender != channelSettlement) revert OnlyChannelSettlement();
    if (asset == address(0) || amount == 0) revert Errors.InvalidAmount();

    uint256 res = _reservedBalance[asset][user];
    if (res < amount) revert InsufficientReservedBalance();

    _reservedBalance[asset][user] = res - amount;
    emit Released(user, asset, amount);
}
```

### Why “reserve doesn’t move funds”?

Because funds are already inside the vault contract. Reserve is a **withdraw constraint**, not a separate pot.

---

# Patch 2 — ChannelSettlement: compute reserves on submit, store in Pending, reserve in MAV

You need to reserve **per user** based on **net debit** implied by deltas.

## 2.1 Definition: what to reserve

For each user `u`, compute:

* `netCash_u = sum(netCashDelta for u)` **after fees** (same net cash used in `_applyCashDeltasAndFees`)
* required reserve = `max(0, -netCash_u)`

This guarantees:

* if finalize needs to debit user, user cannot withdraw the debit amount during challenge window.

## 2.2 Pending struct changes (minimal)

Add to your `Pending` struct:

```solidity
address settlementAsset; // for release routing & replace safety
address[] reserveUsers;  // bounded by MAX_USERS (256)
uint256[] reserveAmts;   // same length
uint64 createdAt;        // for cancel timeout
```

Notes:

* storing arrays in `Pending` is okay because it is bounded (256) and only exists while pending.

## 2.3 Reserve computation helper (bounded O(n^2) ok at 256)

Inside ChannelSettlement, add:

```solidity
function _computeReserves(
    uint256 marketId,
    bytes32 sessionId,
    ShadowTypes.Delta[] calldata deltas,
    address settlementAsset
) internal view returns (address[] memory users, uint256[] memory amts) {
    // We need per-user aggregation, bounded by 256.
    // Approach:
    // 1) build unique user list
    // 2) compute netCash per user (after fee split)
    // 3) reserve = max(0, -netCash)

    uint256 n = deltas.length;
    address[] memory uniq = new address[](n);
    int256[] memory net = new int256[](n);
    uint256 ucount = 0;

    FeeManager fm = feeManager;

    for (uint256 i = 0; i < n; i++) {
        address u = deltas[i].user;
        int128 cd = deltas[i].cashDelta;
        if (cd == 0) continue;

        // apply same fee logic as finalize uses (must match!)
        int128 nd = cd;
        if (address(fm) != address(0) && cd > 0) {
            (, , , int128 netDelta) = fm.computeSplit(cd);
            nd = netDelta;
        }

        // find or insert user (bounded 256 so linear scan ok)
        uint256 idx = type(uint256).max;
        for (uint256 j = 0; j < ucount; j++) {
            if (uniq[j] == u) { idx = j; break; }
        }
        if (idx == type(uint256).max) {
            idx = ucount;
            uniq[ucount] = u;
            net[ucount] = 0;
            ucount++;
        }
        net[idx] += int256(int128(nd));
    }

    // count debtors
    uint256 dcount = 0;
    for (uint256 i = 0; i < ucount; i++) {
        if (net[i] < 0) dcount++;
    }

    users = new address[](dcount);
    amts = new uint256[](dcount);
    uint256 k = 0;
    for (uint256 i = 0; i < ucount; i++) {
        if (net[i] < 0) {
            users[k] = uniq[i];
            amts[k] = uint256(-net[i]);
            k++;
        }
    }
}
```

✅ This ensures reserve computation matches your fee-adjusted cash deltas.

## 2.4 Apply reserves in submitCheckpoint

In `submitCheckpoint` / `submitCheckpointFromPayload`, after you’ve validated signatures + stored `Pending`, do:

1. compute settlementAsset (same rule as finalize)
2. compute reserve arrays
3. call MAV.reserve for each
4. store arrays into Pending

Pseudo:

```solidity
address settlementAsset = _resolveSettlementAsset(marketId); // same as finalize uses
(address[] memory rUsers, uint256[] memory rAmts) =
    _computeReserves(marketId, sessionId, deltas, settlementAsset);

// reserve in MAV
if (address(multiAssetVault) != address(0)) {
    for (uint256 i=0; i<rUsers.length; i++) {
        multiAssetVault.reserve(rUsers[i], settlementAsset, rAmts[i]);
    }
} else {
    // If you support CV-only path, add reserve/release there too (recommended)
    VAULT.reserve(rUsers[i], rAmts[i]); // add same concept to CV OR disallow CV mode
}

// store into pending
pendingByKey[k].settlementAsset = settlementAsset;
pendingByKey[k].reserveUsers = rUsers;
pendingByKey[k].reserveAmts = rAmts;
pendingByKey[k].createdAt = uint64(block.timestamp);
```

**Critical:** Reserve must happen **after** you decide this checkpoint is now pending, but **before** returning, so withdrawals are blocked during challenge window.

---

# Patch 3 — Replace-pending logic: release old reserves before reserving new ones

Your protocol supports “latest signed state wins” (replacement within challenge window). When new checkpoint replaces pending:

✅ must release old pending reserves
✅ then reserve new ones
✅ then overwrite pending fields

## 3.1 Add helper `_releasePendingReserves`

```solidity
function _releasePendingReserves(bytes32 k, Pending storage p) internal {
    if (p.reserveUsers.length == 0) return;

    address asset = p.settlementAsset;
    if (address(multiAssetVault) != address(0)) {
        for (uint256 i=0; i<p.reserveUsers.length; i++) {
            multiAssetVault.release(p.reserveUsers[i], asset, p.reserveAmts[i]);
        }
    } else {
        // CV path: implement release similarly or disallow CV-only mode
        VAULT.release(p.reserveUsers[i], p.reserveAmts[i]);
    }
}
```

## 3.2 In submitCheckpoint replacement branch

When you detect replacement (new nonce > pending nonce and within challenge window):

* call `_releasePendingReserves(k, pendingByKey[k])`
* then compute & reserve for the new checkpoint
* overwrite p fields

This avoids “reserve leak”.

---

# Patch 4 — cancelPendingCheckpoint escape hatch

If pending never finalizes (relayer disappears, challenge grief, etc.), reserves remain stuck forever unless you can cancel.

## 4.1 New constant

```solidity
uint64 public constant CANCEL_DELAY = 6 hours; // pick a policy value
```

## 4.2 New function

```solidity
function cancelPendingCheckpoint(uint256 marketId, bytes32 sessionId) external {
    bytes32 k = _key(marketId, sessionId);
    Pending storage p = pendingByKey[k];
    if (!p.exists) revert Errors.NoPending();
    if (block.timestamp < uint256(p.createdAt) + CANCEL_DELAY) revert Errors.CancelTooEarly();

    // release reserves
    _releasePendingReserves(k, p);

    // delete pending
    delete pendingByKey[k];

    emit PendingCheckpointCancelled(marketId, sessionId, p.nonce);
}
```

## 4.3 Add event

```solidity
event PendingCheckpointCancelled(uint256 indexed marketId, bytes32 indexed sessionId, uint64 nonce);
```

---

# Important design note: CollateralVault mode

Right now MAV has deposit/withdraw and will gain reserve/release.

If you still support `CollateralVault` (single-asset) as fallback, you have 2 safe options:

### Option A (recommended): add reserve/release to CollateralVault too

Mirror the same `_reservedBalance[user]` and the same withdraw restriction.

### Option B (strict): disallow finalize in CV-only mode for production

E.g., require MAV configured when escrow-safe mode enabled.

Given you already use MAV on Fuji, I’d do Option A (it’s small).

---

# Final safety properties gained

After these patches, RetroPick becomes safe against:

✅ “withdraw-to-grief” during pending checkpoint
✅ replacement leaking reserves
✅ stuck pending permanently freezing funds
✅ mismatched fee/reserve math (if you also add the accounting invariant later)

---

# Implementation order (fastest safe)

1. Patch MAV (reserve/release + withdraw check)
2. Patch ChannelSettlement submit path to reserve + store arrays
3. Patch replacement path release old reserves
4. Add cancel function
5. Add tests (below)

---

# Tests to add (names matching your style)

### `test_Escrow_WithdrawBlockedByReserve()`

* deposit 100
* submit pending checkpoint that requires reserve 60 (net cash delta -60)
* withdraw 50 should revert (available is 40)

### `test_Escrow_ReserveReleasedOnFinalize()`

* submit pending with reserve
* warp past challenge
* finalize
* reserved becomes 0
* withdraw now succeeds

### `test_Escrow_ReserveReplacedOnNewCheckpoint()`

* submit pending A with reserve 60
* submit replacement B with reserve 20
* assert reserved now 20 (not 80)

### `test_Escrow_CancelPendingReleasesReserve()`

* submit pending reserve
* warp + CANCEL_DELAY
* cancel
* reserved released, pending deleted

---

## If you paste those two missing items later…

If you later paste:

* `Pending struct` (exact fields today)
* `submitCheckpoint` / `submitCheckpointFromPayload`

…I can rewrite the above into a **literal line-by-line diff** that matches your exact code layout, including trimming arrays, error names, and how you do storage (memory vs storage arrays). But you can already implement safely using this spec as-is.
