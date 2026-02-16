Below is a **full, smart-contract-only refactor plan** that turns your current repo into an “institutional-grade, curated, multi-asset, multi-chain-ready” system **without breaking your existing flows**.

I’ll give you:

1. **What to fix right now (P0)**
2. **What to delete / deprecate**
3. **What to upgrade / refactor per contract**
4. **What to add (new contracts)**
5. **How fees + treasury should work (exact settlement enforcement)**
6. **How curated AI drafts → user claim → CRE publish should work**
7. **CCIP + multi-chain/multi-asset topology (minimal, correct MVP)**
8. **Repository structure changes**
9. **PR plan + tests**

---

# 0) Executive verdict on your current code

You’re **very close** to the correct “Yellow-ready” onchain core because:

* `ChannelSettlement + ExecutionLedger + CollateralVault + MarketRegistry` is the right skeleton.
* You already have a routing layer (`CREReceiver → OracleCoordinator → SettlementRouter`) that can support multiple message types and future branching.

But it is **not safe / not enforceable enough** for the “exact design” you want until you address:

### Hard blockers (must fix)

* **Unrestricted privileged functions**:

  * `MarketRegistry.resolve()` unrestricted → anyone can resolve markets.
  * `ReportValidator.setMinConfidence()` unrestricted.
  * `Treasury.setMarketApproved()` unrestricted.
* **Checkpoint signer coverage is incomplete**:

  * `ChannelSettlement` currently allows a checkpoint to apply deltas for a user who didn’t actually sign (if `users[]` / `userSigs[]` aren’t enforced against `deltas[].user`).
* **Single-asset vault** (`CollateralVault(tokenAddress)`) conflicts with:

  * “deposit from any chain”
  * “market can be made in any chain”
  * “not specific 1 asset”
* **Fees are not enforceable onchain yet**:

  * you need a fee module and hard caps.

---

# 1) What to DELETE / DEPRECATE (cleanly)

## 1.1 Deprecate pool path as “Legacy module”

You currently have both `PredictionMarket` and `LegacyPoolMarket`, which are nearly identical. Keep **only one** if you want a demo.

**Action**

* ✅ Keep: `LegacyPoolMarket` (rename to `PoolMarketLegacy`)
* ❌ Deprecate: `PredictionMarket` (or vice versa)
* Make the legacy module explicitly “not used in production path”

Why: institutions/auditors will treat duplicate logic as risk and maintenance debt.

## 1.2 Deprecate `SessionFinalizer` as fallback-only

`SessionFinalizer` is not compatible with your “vault + ledger + settlement” model because it directly transfers balances.

**Action**

* Keep it only as a fallback demo path behind a router flag.
* Do not use it in the main settlement pipeline once fees + vault + ledger are in place.

---

# 2) What to UPGRADE / CHANGE (per existing contract)

## 2.1 `ReportValidator.sol` (P0 security)

### Problem

`setMinConfidence(uint16)` is currently public/unrestricted.

### Change

* Add `onlyOwner` (or AccessControl `RISK_ADMIN_ROLE`)
* Emit event `MinConfidenceUpdated(old,new)`

Also: you’ll eventually want confidence policies **per-market** or **per-resolution playbook**, not global.

**Upgrade path**

* P0: `onlyOwner`
* P1: `ConfidencePolicyRegistry` (marketType → threshold) or (playbookHash → threshold)

---

## 2.2 `Treasury.sol` (P0 security + role model)

### Problem

`setMarketApproved()` unrestricted → any attacker can approve themselves and drain.

### Change

* Add `onlyOwner`
* Add `approvedMarkets` gating remains fine, but add `Treasury` is *not* your treasury fund long-term—this is an escrow helper.

**Recommendation**

* Long-term, replace `Treasury.sol` with `FeePool/TreasuryPool` (see Section 4).
* Keep `Treasury.sol` optional and legacy.

---

## 2.3 `MarketRegistry.sol` (P0 + core lifecycle)

### Problems

* `resolve()` unrestricted.
* No explicit OPEN/FROZEN/RESOLVED market lifecycle (you have Draft/Active/Resolved implied).
* No enforced freeze boundary for “no trade after close”.

### Mandatory changes

1. **Access control**

* `resolve()` must be callable only by:

  * `SettlementRouter` (recommended), OR
  * `ResolutionManager` (once you implement it)
* Add `onlySettlementRouter` modifier.

2. **Explicit lifecycle + timestamps**
   Add fields:

* `tradingOpen`
* `tradingClose`
* `resolveTime`
* `status: Draft → Open → Frozen → Resolved`

Add methods:

* `freeze(marketId)` permissionless when `block.timestamp >= tradingClose`
* `setStatusOpen(marketId)` if you need delayed start (optional)

3. **Enforce settlement constraints**
   Your checkpoint settlement must bind to this rule:

> A checkpoint is valid only if `checkpoint.lastTradeAt <= tradingClose` AND market is `Open`/`Frozen` (not resolved).

So `ChannelSettlement.finalizeCheckpoint()` should check market state.

**Integration**

* `ChannelSettlement` must read `MarketRegistry.getMarketTimes(marketId)` or `MarketRegistry.tradingClose(marketId)`.

---

## 2.4 `SettlementRouter.sol` (routing + audit events)

### Current: good modular switch (market settle + session finalize).

### Needed:

* stronger audit eventing
* typed message routing policy
* explicit receiver whitelist (optional)

**Changes**

* Emit structured events:

  * `MarketOutcomeSettled(market, marketId, outcomeIndex, confidence, reportHash)`
  * `SessionPayloadRouted(route, payloadHash, marketId, sessionId)`
    where `route` = `ChannelSettlement` or `SessionFinalizer`

* Add optional whitelist / registry:

  * `approvedMarketReceivers[addr] = true`
  * prevent coordinator from settling arbitrary target contracts.

This is **very important** for institutions: they hate “router can call any address”.

---

## 2.5 `OracleCoordinator.sol` (future-proof resolution manager)

Currently it forwards “result tuple” and “session payload” only.

**Upgrade**
Add a v2 route for resolution proposals:

* `submitResolutionProposal(bytes proposalPayload)` to a `ResolutionManager`

But do not overcomplicate P0. For now:

* keep your current coordinator
* just ensure it can only be called by `CREReceiver`

---

## 2.6 `CREReceiver.sol` (schema versioning)

Add versioning to payloads to avoid lock-in and ambiguity.

Right now you rely on:

* `0x03` = session payload
* else = result tuple

**Upgrade**
Make it explicit:

* `0x01`: resolve market
* `0x02`: create market (legacy MarketFactory)
* `0x03`: checkpoint submission
* `0x04`: publish-from-draft (new curated pipeline)
* `0x05`: risk params update (future)
* `0x06`: CCIP mirrored status update (future)

This matters because CRE workflows evolve fast.

---

## 2.7 `ChannelSettlement.sol` (P0 correctness + fee hook + market state binding)

This is your most important contract.

### P0 fixes (must)

1. **Signer coverage**
   Enforce:

* Every unique `deltas[i].user` must be included in `users[]`
* Each included user must have a valid signature over the same digest

Implementation approach:

* Build a mapping `signed[user] = true` from `users[]`
* During delta loop: `require(signed[d.user])`
* Also require **no duplicate users** in `users[]` (otherwise weird replay)

2. **Market lifecycle binding**
   Require:

* market exists
* `cp.lastTradeAt <= MarketRegistry.tradingClose(marketId)`
* market not resolved
* checkpoint `validAfter/validBefore` must also respect time window

3. **Fee enforcement hook**
   `finalizeCheckpoint()` must call `FeeManager` to compute & collect fees.

Even if Yellow “accounts” fees, onchain recomputes from deltas.

### P1 upgrades (nice but not required for MVP)

* add v2 checkpoint schema fields: `epoch`, `accountsRoot`, `txRoot`, `prevStateHash`, `policyHash`
* add sentinel hook: `RiskSentinel.forceCheckpoint(...)` or `pause`

---

## 2.8 `ExecutionLedger.sol` (multi-asset + solvency stats)

It currently stores outcome shares only.

To support institutional controls and future risk, you want:

* per-market aggregated OI
* per-user cash net (optional)
* a “position vector hash” for audit

But you can keep it simple:

**P0**

* keep as is
* ensure it cannot go negative (you already enforce non-negative invariant)

**P1**

* add market-level stats:

  * `totalSharesByOutcome[marketId][outcome]`
  * `openInterest[marketId]` (sum)
* add “position checkpoint hash storage” per session for audit

---

## 2.9 `CollateralVault.sol` → MUST become multi-asset (core requirement)

Right now it’s single ERC20.

Your stated requirement is:

> user deposits can be from any chain and market can be made in any chain (NOT SPECIFIC 1 asset)

Onchain reality:

* Multi-chain deposit implies bridging.
* “Not specific 1 asset” implies vault supports multiple ERC20 assets.

### Replace/Upgrade

Create: `MultiAssetVault.sol` (or upgrade CollateralVault)

State:

* `mapping(address asset => mapping(address user => uint256 free))`
* `mapping(bytes32 lockKey => uint256 locked)` but lockKey must include asset.

Functions:

* `deposit(asset, amount)`
* `withdraw(asset, amount)`
* `applyCashDeltas(asset, users, deltas)` or deltas include asset
* `redeemPayout(asset, to, amount)`

**Important**
Deltas must be denominated in a single settlement asset per market OR you support an asset basket policy.
For MVP, do:

* market has `settlementAsset` (ERC20)
* all cash deltas and payouts are in that asset
* deposits can be multiple assets only if you add conversion logic (data feeds). Don’t do that until P2.

So P0/P1:

* multi-asset vault exists
* each market chooses a settlement asset
* deposits must be in that asset (enforced).

---

# 3) What to ADD (new contracts to meet your “exact design”)

## 3.1 Fee system (must be enforceable at settlement)

### A) `FeeManager.sol` (policy + caps)

Store:

* `protocolFeeBps`
* `MAX_PROTOCOL_FEE_BPS` constant
* optional: `creatorFeeBps`, `referrerFeeBps`, `MAX_TOTAL_BPS`

Rules:

* `protocolFeeBps <= MAX_PROTOCOL_FEE_BPS`
* if you add other fees: `protocol + creator + referrer <= MAX_TOTAL_BPS`

Expose:

* `computeFee(int128 pnlDelta) returns (uint256 fee, int128 netDelta)`
  (only takes fee on positive pnl)

### B) `FeePool.sol` (holds fees per asset)

* receives fees
* emits `FeeCollected(asset, amount, marketId, sessionId)`
* can sweep to treasury

### C) `TreasuryPool.sol` (protocol treasury)

* receives sweeps
* controlled spending via governance/owner, emits events for every spend

**Where fee is applied**

* In `ChannelSettlement.finalizeCheckpoint()`, right after deltas verification and before vault updates are finalized.

This matches your Option 2 and cannot be bypassed.

---

## 3.2 Curated Market Supply: Draft → Claim → Publish (your new requirement)

You already have *some* of this in `MarketFactory` (payload validation, requestedBy signatures), but it’s not a true draft lifecycle.

Add these:

### A) `MarketDraftBoard.sol`

Stores curated drafts.

Fields (minimum):

* `draftId`
* `questionURI` / `questionHash`
* `marketType`, outcomes/timeline windows
* `resolveSpecHash` (source of truth policy)
* `times`: open/close/resolve
* `status`: Proposed/Claimed/Published/Cancelled/Expired
* optional: `trustScore`, `playbookHash`, `liquidityBandHash`

Who can propose drafts:

* `onlyOwner` or `AI_ORACLE_ROLE`

### B) `DraftClaimManager.sol`

Lets users claim a draft with bond/seed requirement.

* `claimDraft(draftId, bond, seedCommitment, sig)`
* stores `creatorOfDraft[draftId] = user`

### C) `CREPublishReceiver.sol`

CRE entrypoint to publish a claimed draft onchain.

Validates:

* draft exists and is claimed
* claimer signature binds to the draft
* policy checks

Calls:

* `MarketFactory.createFromDraft(draftId, creator, paramsHash/URI)`

### D) `MarketPolicy.sol`

Enforces curated rules:

* allowed resolve specs
* allowed market types
* max outcomes
* min duration
* required seed

**Why institutions like this**
They want to see that the venue is not a spam free-for-all and that resolution sources are approved.

---

## 3.3 Resolution model (bond/evidence/escalation) — P1/P2

Right now you resolve directly via CRE with confidence only.

Add:

### `ResolutionManager.sol`

* `proposeResolution(marketId, outcome, confidence, evidenceHash, bond)`
* `challengeResolution(marketId, counterEvidenceHash, bond)`
* finalize after dispute window

`MarketRegistry.resolve()` becomes internal / only callable by ResolutionManager after finalization.

This is optional for MVP, but it’s the biggest gap vs “institutional-grade”.

---

## 3.4 CCIP layer (P3 but design now so you don’t rewrite later)

Add:

### `CCIPGateway.sol` (adapter)

* receives CCIP messages
* updates onchain facts only:

  * market status replication
  * resolution replication
  * settlement root replication
  * payout instruction replication (optional)

**Critical MVP topology**
Pick a **hub chain** as canonical custody:

* Vault lives on hub chain.
* Other chains can have MarketRegistry mirrors or lightweight “MarketMirror”.
* Settlement roots/deltas sent to hub for applying to the vault.

Trying “vault everywhere” is a reconciliation nightmare.

---

# 4) What to KEEP but REWIRE

## Keep:

* `ReceiverTemplate`
* `CREReceiver`
* `OracleCoordinator`
* `SettlementRouter`
* `ChannelSettlement`
* `ExecutionLedger`
* `MarketRegistry` (but fix access control + lifecycle)

## Rewire:

* Market creation: move from generic `MarketFactory` payloads to **draft-based publish**
* Settlement fee: add `FeeManager` hook inside `ChannelSettlement.finalizeCheckpoint`
* Vault: replace `CollateralVault` with multi-asset vault; MarketRegistry redemption uses market’s settlement asset.

---

# 5) Concrete “Full Change List” (do this / delete that)

## P0 (immediate, must)

1. Add access control:

* `MarketRegistry.resolve` → only router / resolution manager
* `ReportValidator.setMinConfidence` → onlyOwner
* `Treasury.setMarketApproved` → onlyOwner

2. Fix checkpoint signature coverage:

* require signature for each delta user

3. Replace hardcoded token:

* `PredictionMarket`/`LegacyPoolMarket` constructors take token address

4. Add router receiver allowlist:

* only allow settling approved market receiver contracts

5. Add `MarketRegistry.freeze()` + enforce checkpoint `lastTradeAt <= tradingClose`

---

## P1 (core parity)

6. Implement Fee stack:

* `FeeManager` + `FeePool` + `TreasuryPool`
* enforce fee at settlement time (ChannelSettlement finalize)

7. Add curated market supply:

* `MarketDraftBoard`
* `DraftClaimManager`
* `CREPublishReceiver`
* modify `MarketFactory` → `createFromDraft`

8. Make vault multi-asset:

* upgrade `CollateralVault` → `MultiAssetVault`
* market has settlement asset

---

## P2 (whitepaper power features)

9. Add `ResolutionManager` (bond/evidence/dispute)
10. Add checkpoint v2 fields: epoch/accountsRoot/txRoot/prevStateHash/policyHash
11. Add `RiskManager` for caps + sentinel hooks

---

## P3 (cross-chain)

12. Add `CCIPGateway` + hub-spoke custody
13. Add “market mirror” contracts if needed

---

# 6) Repository structure changes (clean and audit-friendly)

### Current

* `src/core`
* `src/oracle`
* `src/execution`
* `src/libs`
* `src/interfaces`

### Proposed

```
src/
  core/
    MarketRegistry.sol
    MarketFactory.sol              // now “publish claimed drafts”
    PoolMarketLegacy.sol           // optional legacy module

  curation/                        // NEW
    MarketDraftBoard.sol
    DraftClaimManager.sol
    MarketPolicy.sol
    CREPublishReceiver.sol

  execution/
    ChannelSettlement.sol          // add fee hook + lifecycle checks
    ExecutionLedger.sol
    MultiAssetVault.sol            // replaces CollateralVault

  fees/                            // NEW
    FeeManager.sol
    FeePool.sol
    TreasuryPool.sol

  resolution/                      // P2
    ResolutionManager.sol

  crosschain/                      // P3
    CCIPGateway.sol

  oracle/
    CREReceiver.sol
    OracleCoordinator.sol
    SettlementRouter.sol
    ReportValidator.sol

  libs/
  interfaces/
```

This prevents “core vs execution vs curation” from mixing and makes audits easier.

---

# 7) Tests you must add (non-negotiable if you want correctness)

## P0 tests

1. `MarketRegistry.resolve` unauthorized should revert
2. `ReportValidator.setMinConfidence` unauthorized should revert
3. `Treasury.setMarketApproved` unauthorized should revert
4. Checkpoint with unsigned delta user should revert
5. Finalize checkpoint after tradingClose but with `lastTradeAt > tradingClose` should revert

## P1 tests

6. Fee cap enforcement (cannot set > MAX)
7. Fee applied only on positive pnl
8. Fee routed to FeePool and sweepable to TreasuryPool
9. Draft pipeline:

* propose draft
* user claims
* CRE publish creates market with correct params

---

# 8) Final guidance on “what contract does what” (your exact question)

### Which contract is only for settlement?

✅ `ChannelSettlement`

* verifies checkpoint signatures
* enforces freeze boundary
* applies deltas to ledger + vault
* computes and collects fees (calls FeeManager)

### Which contract is only for creation?

✅ `MarketFactory` + `CREPublishReceiver` + `MarketDraftBoard`

* DraftBoard: curated inventory
* ClaimManager: maker claim + bond
* PublishReceiver: CRE ingress
* Factory: actual onchain market creation

### Which contract applies fee pool + treasury pool?

✅ Settlement time only:

* `FeeManager` calculates
* `FeePool` receives
* `TreasuryPool` holds long-term funds

---

If you want the next step, paste **actual Solidity code** for these 3 first (they’re the most critical), and I’ll give you a **patch-level change list** (function signatures + exact modifiers + exact new storage vars + events):

1. `ChannelSettlement.sol`
2. `MarketRegistry.sol`
3. `CollateralVault.sol` (or your planned replacement)

Then I’ll do `SettlementRouter`, `ReportValidator`, and the curated draft contracts.

Below is a **senior-level, smart-contract-only audit + refactor doc** for the 3 contracts you pasted: **ChannelSettlement.sol, MarketRegistry.sol, CollateralVault.sol**.

I’m going to be blunt and very specific: what’s correct, what’s dangerous, what must change for your target architecture (Yellow execution, settlement fees, curated creation, CRE automation, CCIP later, multi-asset later).

---

# 1) ChannelSettlement.sol — Deep Review & Required Upgrades

## 1.1 What’s good already

* ✅ Challenge window exists (`CHALLENGE_WINDOW_SECONDS`) and you store a pending checkpoint.
* ✅ Nonce monotonicity is enforced (`cp.nonce > latestNonce`).
* ✅ You verify:

  * operator signature over checkpoint
  * user signatures over the checkpoint digest
  * deltas hash matches checkpoint `cp.deltasHash`

This is a solid start.

---

## 1.2 Critical security flaw: signer coverage is NOT enforced

### Problem

You verify that `users[i]` signed the checkpoint digest, **but you do NOT verify that every `deltas[i].user` is included in `users[]`**.

That means an operator can submit a checkpoint that includes deltas for a user who didn’t sign — as long as it includes *some* other users who signed.

**Consequence:** funds can be debited for non-signers (via vault cashDelta negative) or shares changed (via ledger.applyDeltas) without their consent.

### Fix (mandatory P0)

Enforce:

* `users[]` must contain **all unique delta users**
* `users[]` must not contain duplicates
* `userSigs[]` must correspond exactly

**Implementation pattern**

* Build an in-memory mapping-like structure:

  * If you keep `MAX_USERS=256`, you can do O(n²) duplicate checks safely.
  * Or use a temporary `address => bool` mapping via a separate storage “seenNonce” trick (messy), so do O(n²).

Pseudo-logic:

* verify users unique
* build `signedUsers[]` set
* in delta loop: `require(isSigned(deltas[i].user))`

---

## 1.3 Challenge mechanism is incomplete for “latest state wins”

Right now:

* `challengeCheckpoint` replaces pending checkpoint if higher nonce within window.
* But **only if the challenger provides `operatorSig`**.

### Problem

If the operator is malicious/censoring, they can refuse to sign the newer checkpoint, blocking challenges.

### Correct model (for non-custodial perception)

You need one of these:

**Option A (recommended): allow user-submitted checkpoints without operatorSig**

* Require signatures from *all users affected* (or a quorum rule).
* OperatorSig becomes optional; if absent, require stricter user coverage.

**Option B: user exit proof**

* User can submit their own latest signed state leaf (Merkle or direct) and force settlement of their balance.
* This is more complex but is the real “state channel safety valve”.

Given your current struct uses full deltas array, Option A is simplest.

---

## 1.4 finalizeCheckpoint allows anyone (fine), but lacks market lifecycle enforcement

You must prevent finalizing sessions that contain trades after trading close / freeze.

Your checkpoint struct has:

* `validAfter`, `validBefore` (good), but those are not tied to market tradingClose.

### Fix (mandatory for Yellow correctness)

Integrate `MarketRegistry` and check:

* market exists
* market status is `Active` or `Frozen` (not Resolved)
* and checkpoint must respect market timing boundary.

**Need a field**
Add to `ShadowTypes.Checkpoint`:

* `uint48 lastTradeAt;` (or `stateTimestamp`)
  Then enforce:
* `cp.lastTradeAt <= MarketRegistry.tradingClose(marketId)`

If you don’t want to edit types yet:

* enforce via `validBefore = tradingClose` at checkpoint signing time
* but still: you need onchain to verify `validBefore <= tradingClose`.

---

## 1.5 Fee enforcement is missing (your Option 2 requirement)

You want: “Take Fee On Settlement Contract”.

That means:

* ChannelSettlement must call FeeManager during finalize
* Fee must be computed **from actual deltas**, not trusted from operator.

### Correct model for you (simple + enforceable)

**Settlement fee on positive realized PnL (per checkpoint)**:

* For each user, compute `pnl = cashDelta` (if your engine encodes pnl as cashDelta net)
* if `pnl > 0`: fee = pnl * feeBps / 10_000
* user receives `pnl - fee`
* treasury receives fee

Where does it apply?

* Either:

  * adjust the cashDeltas before calling `vault.applyCashDeltas`, and separately transfer fee to FeePool
* Or:

  * call `vault.applyCashDeltasNetOfFees` and `vault.creditFeePool`

**You currently don’t have fee plumbing in CollateralVault**, so you’ll need it.

---

## 1.6 Gas & memory inefficiencies (not fatal, but easy wins)

* You do `usersTrimmed/cashDeltasTrimmed` by creating arrays twice.
* With MAX_DELTAS small this is ok, but you can do better:

  * pre-count, allocate exact size once, fill once.

Also: `Pending memory p = pendingByKey[k];` then delete pending. Fine.

---

## 1.7 Error hygiene: using revert("...") strings is ok but inconsistent

You use raw strings and also `revert()` in setOperator. This hurts debugging.

**Fix**
Introduce `Errors.sol` usage in ChannelSettlement (consistent typed errors):

* `error TooManyDeltas();`
* `error TooManyUsers();`
* etc.

---

## 1.8 Changes summary for ChannelSettlement (what to change)

### MUST (P0)

1. Enforce delta-user signature coverage
2. Add “user can challenge without operator sig” OR add user exit hatch
3. Market lifecycle gating (freeze boundary)
4. Fee hook at finalize

### SHOULD (P1)

5. Add checkpoint v2 fields (`epoch/accountsRoot/txRoot/prevStateHash`)
6. Add sentinel hooks (`pause/forceCheckpoint`)

---

# 2) MarketRegistry.sol — Deep Review & Required Upgrades

## 2.1 Critical vulnerability: resolve() is publicly callable

You already identified this in your own doc: it’s a real blocker.

### Problem

`resolve(marketId, winningOutcome, confidence)` calls `_doResolve` with no access control.

Anyone can resolve any market at any time with arbitrary outcome.

### Fix (mandatory P0)

Make resolve restricted:

* `onlySettlementRouter` OR `onlyResolutionManager`

You already have `settlementRouter` stored and `onReport` checks it.

So do:

```solidity
function resolve(...) external override {
  if (msg.sender != settlementRouter) revert UnauthorizedRouter();
  _doResolve(...);
}
```

Then you can later move to `ResolutionManager`.

---

## 2.2 Your market “Status” is not correct for Yellow lifecycle

Currently you return:

* Draft if no creator
* Active if not settled
* Resolved if settled

But you need:

* Draft → Open → Frozen → Resolved

### Why Frozen matters

Because you need a hard boundary where Yellow must stop trading and settlement must reject “post-close” trades.

### Fix (P0/P1 depending)

Add to `Market`:

* `uint48 tradingOpen`
* `uint48 tradingClose`
* `uint48 resolveTime` (or use expiry as resolveTime, but you’re using expiry as Texpiry)
* `Status status` stored explicitly

Add methods:

* `freeze(marketId)` permissionless after close
* maybe `open(marketId)` if delayed

---

## 2.3 `expiry` is ambiguous and currently unused in enforcement

You set `expiry` in Market creation, but:

* you do not enforce it anywhere.
* your comments say it’s “Texpiry from whitepaper; 0 = no expiry enforced”.

### Fix

Decide what `expiry` means and enforce it:

* If it is `resolveTime`, then:

  * disallow settlement before resolveTime (or allow but mark)
* If it is “market validity cutoff”:

  * enforce no trading after expiry (freeze boundary)
  * allow resolve after expiry

Most protocols do:

* tradingClose <= resolveTime
* after tradingClose market is frozen
* resolution at/after resolveTime

So: rename fields for clarity; don’t overload expiry.

---

## 2.4 redeem() payout logic is not economically correct yet

You do:

* `shares = ledger.positionOf(user, marketId, winningOutcome)`
* payout = uint256(shares)
* vault transfers payout

This assumes:

* “1 share = 1 token payout” always
* ledger shares are already netted to final claimable token amount

That can be okay **only if** your Yellow engine encodes outcome shares as a fully-collateralized claim token at settlement time.

But be careful:

### If your engine uses LMSR-style “shares”

Then `shares` represent units of outcome tokens, and payout is `shares * payoutPerShare`, usually payoutPerShare = 1 unit of collateral (if fully collateralized). That’s okay.

But you also need:

* ensure vault has enough to pay all winners
* ensure losers paid cost earlier (cashDelta negative)
* ensure fee deducted before redeem or during settlement

So to make this consistent:

* enforce that settlement contract makes vault solvent (RiskManager later)
* integrate fees either:

  * at settlement (recommended)
  * or at redeem (but less clean for accounting)

---

## 2.5 Storage is heavy (question stored onchain)

Not “wrong”, but for large scale:

* storing full question strings is expensive.

Given you plan “draft board + AI curated list”, you should:

* store `questionURI` or `questionHash`
* keep the plain string optional for demo

---

## 2.6 Changes summary for MarketRegistry

### MUST (P0)

1. Restrict `resolve()`
2. Add explicit lifecycle support or at least tradingClose boundary fields
3. Add enforcement hooks for settlement contract to read tradingClose/status

### SHOULD (P1)

4. Replace question string with URI/hash
5. Integrate `ResolutionManager` (bond/evidence)

---

# 3) CollateralVault.sol — Deep Review & Required Upgrades

## 3.1 Single-asset design conflicts with your roadmap

You want:

* multi-asset markets
* cross-chain deposit eventually

This vault is:

* `IERC20 immutable tokenContract`
* single balances mapping

### Fix roadmap

**P0:** Keep single asset for MVP but remove anti-patterns + prepare interfaces.
**P1:** Replace with `MultiAssetVault` (new contract) and update interfaces.
**P3:** Add CCIP router integration.

Don’t try to “half-multi-asset” by bolting mapping(asset=>...) into this exact contract if you also want ERC-4626 later—better to split now.

---

## 3.2 Transfer return values and error codes are wrong/inconsistent

You do:

```solidity
if (!tokenContract.transferFrom(...)) revert Errors.InvalidAmount();
```

* `InvalidAmount` is not a transfer failure error.
* Some ERC20s don’t return bool properly (non-standard). OZ `SafeERC20` should be used.

### Fix (P0)

Use `SafeERC20`:

* `SafeERC20.safeTransferFrom`
* `SafeERC20.safeTransfer`

Add proper errors:

* `TransferFailed()` or reuse `Errors.TransferFailed`

---

## 3.3 `setMarketRegistry` bug: you only set if input != address(0)

That means:

* you can’t intentionally clear it
* also no check for address(0) is a weird conditional

### Fix (P0)

Either:

* require non-zero always
* or allow setting zero explicitly but emit it

Given security, require non-zero:

```solidity
if (marketRegistry_ == address(0)) revert Errors.InvalidAddress();
```

---

## 3.4 applyCashDeltas is not safe for fee extraction yet

Right now it:

* credits if delta > 0
* debits if delta < 0
* reverts if insufficient free balance on debit

### Good:

* It’s conservative; prevents negative balances.

### But:

* In Yellow trading, users will spend from locked + free, or from margin/reserved. You currently ignore locked balance in debits.

If you truly intend “lock/unlock” to represent reserved collateral:

* then `applyCashDeltas` should debit from locked first or enforce that deltas never require locked spending.

Right now lock/unlock exists but nothing in ChannelSettlement calls lock/unlock. So locked is unused in practice.

### Decision you must make

Either:
A) **Remove lock/unlock entirely** for MVP and treat freeBalance as all collateral
or
B) Make Yellow engine + settlement use lock/unlock to reserve collateral per market/session

Most systems do B, but it requires:

* “available balance” logic per market
* risk checks
* more complexity

Given your “settlement-first fee + PnL accounting” approach, for MVP you can do A:

* remove lock/unlock or keep but unused
* enforce spending only from free balance

But then: your Yellow engine must not create deltas that debit more than free.

---

## 3.5 Missing fee pool / treasury pool hooks

You have `_feesReserve` but you never use it.

### Fix

Either:

* delete `_feesReserve` now (it’s dead state)
* or implement fee handling properly.

Your target design says:

* FeePool and TreasuryPool are separate.

So the correct move:

* remove `_feesReserve`
* implement FeePool contract that holds actual tokens

Settlement should transfer fees by:

* adjusting user credits
* and crediting FeePool by transferring tokens (or by leaving them in vault and accounting to FeePool—don’t do that unless you implement accounting properly)

---

## 3.6 redeemPayout does not check available funds

It just transfers. If vault is insolvent, it fails (transfer fails). That’s ok, but then you need:

* risk manager later
* and better revert reasons.

Use `SafeERC20` and revert with `TransferFailed`.

---

## 3.7 Changes summary for CollateralVault

### MUST (P0)

1. Use SafeERC20
2. Fix setMarketRegistry semantics
3. Remove dead `_feesReserve` or implement fees correctly
4. Decide lock/unlock strategy (remove or integrate)
5. Use proper errors

### SHOULD (P1)

6. Replace with MultiAssetVault + settlementAsset per market
7. Add FeePool/TreasuryPool integration

---

# 4) “Full Changes Doc” — Exactly what to change, delete, integrate

## 4.1 Immediate patch set (P0 PR)

### ChannelSettlement

* Add signer coverage enforcement:

  * `require all deltas[].user ∈ users[]`
  * `require users[] unique`
* Add `MarketRegistry` reference + enforce:

  * market exists
  * not resolved
  * checkpoint respects tradingClose (needs cp.lastTradeAt OR cp.validBefore <= tradingClose)
* Add FeeManager hook placeholder (interface, even if feeBps = 0 now)
* Replace string reverts with custom errors

### MarketRegistry

* Restrict `resolve` to `onlySettlementRouter`
* Add minimal lifecycle fields:

  * `tradingClose` at least (even if tradingOpen omitted)
* Add `getTradingClose(marketId)` view for settlement contract
* (optional) add `freeze()` permissionless and status enum stored

### CollateralVault

* Switch to SafeERC20 and proper transfer errors
* Fix setMarketRegistry semantics (require non-zero)
* Remove `_feesReserve` now
* Decide lock/unlock: keep but unused is okay, but document it and remove from interface later if unused

---

## 4.2 Core integration (P1 PR)

### Add new contracts

* `FeeManager.sol` (caps + feeBps)
* `FeePool.sol`
* `TreasuryPool.sol`

### Integrate

* ChannelSettlement.finalizeCheckpoint:

  * compute fee from deltas
  * apply net cashDelta to users
  * credit fee to FeePool (either by:

    * transferring from vault, OR
    * leaving in vault and minting claim to FeePool—don’t recommend unless vault becomes ERC-4626)

### MarketRegistry redeem

* redeem should remain simple:

  * payout from vault
  * but now vault must be solvent and fees already applied at settlement

---

## 4.3 Multi-asset + CCIP readiness (P2/P3)

* Replace CollateralVault with `MultiAssetVault`
* MarketRegistry stores `settlementAsset` per market
* ChannelSettlement includes `asset` in checkpoint or inferred from market
* CCIP: messages replicate **facts** (market status, resolution, checkpoint roots), not balances

---

# 5) Minimal “Diff-Level” recommendations (most important lines)

## MarketRegistry.resolve fix (must)

```solidity
function resolve(uint256 marketId, uint32 winningOutcome, uint16 confidence) external override {
    if (msg.sender != settlementRouter) revert UnauthorizedRouter();
    _doResolve(marketId, winningOutcome, confidence);
}
```

## ChannelSettlement signer coverage (must)

Add after digest computed:

* uniqueness check for users[]
* “contains” check for every delta user

Because MAX_USERS is 256, simplest is O(n²) loops.

## CollateralVault SafeERC20 (must)

Replace IERC20 transfers with SafeERC20:

* `SafeERC20.safeTransferFrom`
* `SafeERC20.safeTransfer`

---

# 6) Final verdict: can you move to Yellow trading engine now?

Yes **only after**:

* `MarketRegistry.resolve` is locked down
* `ChannelSettlement` enforces delta-user signature coverage
* settlement is tied to trading close boundary (freeze rule)
* (and ideally) fee hook is stubbed so you don’t redesign later

If you skip signer coverage + freeze boundary, your Yellow engine becomes a custody risk even if it’s “state-channel signed”.

---

If you paste **ShadowTypes.Checkpoint** and **ShadowTypes.Delta** next, I’ll tell you exactly which fields you should add (like `lastTradeAt`, `asset`, `epoch`) and I’ll write the clean “v2 checkpoint” struct that keeps backward compatibility with your current tests.

# CHECK

Absolutely — I can produce a **“Change Doc”** right now based on what you’ve shared (your *current* contracts + your *target* curated market pipeline + future Yellow/CRE/CCIP/multi-asset).

This doc is written so you can paste it into `docs/CHANGELOG_ARCHITECTURE.md` or `docs/refactor-plan.md`.

---

# ShadowPool Refactor Doc (Smart Contracts Only)

## Scope

This document describes what to **change**, **delete**, and **integrate** in the current ShadowPool contracts to support:

* **Curated market creation** (AI drafts → user claims → CRE publishes → onchain market created)
* **Creator/MM control** (only approved markets; creators can rebalance via Yellow trades)
* **Fees enforced onchain** with hard caps (BPS with max extractable rule)
* **Treasury pool** for protocol funding & future market incentives
* **Future-proofing** for:

  * Yellow sessions (offchain trading)
  * CRE resolution automation (HTTP evidence, AI scoring)
  * CCIP cross-chain (multi-chain deposits/markets)
  * multi-asset collateral (not 1 token constant)

This is **contract-only**. Offchain systems (AI, DB, API, Yellow operator) are not implemented here — only the onchain interfaces and invariants.

---

## 1) Current contracts (as described)

### Legacy Onchain Prediction Flow

* `PredictionMarket.sol`: market storage + pool betting + settlement + claim
* `MarketFactory.sol`: creates markets from CRE report
* `ReceiverTemplate.sol`: forwarder/workflow validation
* `CREReceiver.sol → OracleCoordinator.sol → SettlementRouter.sol`: oracle routing pipeline
* `SessionFinalizer.sol`: finalize Yellow session by paying balances directly (legacy demo)
* `Treasury.sol`: optional escrow module

### Identified blockers for your “exact design”

1. **Token is fixed** (single `TOKEN_ADDRESS` constant) → incompatible with multi-asset & CCIP.
2. **SessionFinalizer directly pays balances** → incompatible with “vault + ledger + settle + redeem” architecture.
3. **SettlementRouter has weak access control** in your description → unacceptable even for controlled MM pipeline.
4. **No curated “draft → claim → publish” state machine** → users can only create markets directly (or via CRE) with insufficient controls.
5. **No FeeManager** or enforceable cap for protocol extraction.

---

## 2) Target system (what the contracts must become)

### A) Market Supply Pipeline (curated creation)

* AI creates **DraftMarkets offchain**
* Only those drafts can become markets
* Users can **claim** drafts to become creator/MM-of-record
* Claim triggers CRE publish payload
* Onchain verifies and creates market exactly as drafted

### B) Trading & Settlement (Yellow-ready)

* Trading happens in Yellow (later)
* Onchain:

  * holds funds in `CollateralVault`
  * tracks canonical positions in `ExecutionLedger`
  * accepts signed checkpoints in `ChannelSettlement`
  * applies fees and treasury routing at settlement time
  * resolves outcome via CRE
  * redeem is based on ledger + outcome

---

## 3) What to ADD (new contracts/modules)

### 3.1 `MarketDraftRegistry.sol` (NEW)

**Purpose:** Store curated market “candidates” (drafts) in an onchain inventory.

**State**

* `mapping(bytes32 draftId => Draft draft)`
* `enum DraftStatus { Proposed, Claimed, Published, Cancelled, Expired }`

**Draft fields**

* `questionURI` or `questionHash` (avoid storing full strings)
* `marketType`
* `outcomesURI` / `outcomesHash`
* `resolveSpecHash` (source of truth schema)
* `tradingOpen`, `tradingClose`, `resolveTime`
* `collateralPolicyId`, `riskPolicyId`

**Access**

* `onlyOwner` or `AI_ORACLE_ROLE` can propose drafts
* optional: community submissions go to `PendingReview`

---

### 3.2 `DraftClaimManager.sol` (NEW)

**Purpose:** User claims a draft to become the market creator/MM under constraints.

**State**

* `mapping(draftId => Claim)` includes `claimer`, `bond`, `seedCommitment`, `expiry`, status

**Rules**

* Claim requires bond + optional minimum seed
* Claim does not publish market (publish happens through CRE)

**Security**

* EIP-712 signature: claimer binds themselves to `draftId + terms + chainId`
* Prevent claim replay across chains (include `chainId` in digest)

---

### 3.3 `CREPublishReceiver.sol` (NEW, CRE entrypoint)

**Purpose:** This is the single CRE entrypoint that receives “publish market” payload and creates the market.

**Validations**

* Forwarder/workflow validation via `ReceiverTemplate`
* Draft must be `CLAIMED`
* Claimer signature must match
* Draft must pass `MarketPolicy` checks
* Draft must not be expired/cancelled
* Then call `MarketFactory.createFromDraft(...)`

---

### 3.4 `MarketPolicy.sol` (NEW)

**Purpose:** Enforces “not everything can be market” rules *without hardcoding them into the factory*.

**Rules enforced**

* allowed market types
* allowed `resolveSpecHash` categories (approved resolution sources)
* min/max durations
* max outcomes
* min creator seed
* per-user limits (rate limiting via onchain counters if needed)

**Important invariant**

* Policy can be updated by owner, but must **not retroactively change existing markets**.

---

### 3.5 `FeeManager.sol` (NEW) + `FeePool.sol` (NEW) + `TreasuryPool.sol` (NEW)

**Purpose:** Enforce fees onchain with hard caps; route fees; build treasury.

**FeeManager**

* `protocolFeeBps` (mutable by owner)
* `MAX_PROTOCOL_FEE_BPS` (immutable constant; e.g. 200 bps = 2%)
* optional: `creatorFeeBps`, `referrerFeeBps`, and `MAX_TOTAL_BPS`

**FeePool**

* receives fees (per asset)
* tracks accounting
* can sweep to `TreasuryPool` via governance rule

**TreasuryPool**

* long-term protocol funds (incentives, market funding, grants)
* strict authorization for spend

---

## 4) What to CHANGE (existing contracts refactor)

### 4.1 `MarketFactory.sol` — change responsibility

**Current:** CRE report → creates markets directly (binary/typed) in `PredictionMarket`.

**Target:** MarketFactory becomes the *only* minter for `MarketRegistry` markets and supports two creation modes:

1. `createFromDraft(draftId, claimer, params)` (called by `CREPublishReceiver`)
2. optional: `createOwnerMarket(params)` (owner can still create markets directly)

**Change notes**

* MarketFactory should no longer accept arbitrary market payload from random CRE workflow unless it references a valid `draftId`.
* It should record `creator = claimer` in MarketRegistry.

---

### 4.2 `PredictionMarket.sol` — downgrade to legacy/demo path

**Current:** core market logic + custody + payout.

**Target:**

* Keep it as `LegacyPoolMarket.sol` (optional) or keep `PredictionMarket` but remove it from the “main path”.
* No longer the canonical system if you commit to Yellow trading + ledger/vault.

**Why**

* Your exact design wants pricing offchain and settlement via checkpoint.
* Pool-based predict/claim cannot coexist cleanly with ledger-based settlement without confusing users and auditors.

---

### 4.3 `SessionFinalizer.sol` — deprecate for main path

**Current:** validates backend + user signatures and transfers token balances directly.

**Target:**

* Keep for demo only OR delete once ChannelSettlement is ready.
* Replace with `ChannelSettlement` where:

  * settlement applies deltas to `ExecutionLedger`
  * cash movements happen via `CollateralVault`
  * fees enforced via `FeeManager`

---

### 4.4 `SettlementRouter.sol` — tighten access control + add new route

**Must change**

* All setters must be `onlyOwner` (or `AccessControl`)
* Store two targets:

  * `marketResolver` (MarketRegistry or legacy market)
  * `channelSettlement` (for checkpoint finalization)

**Routing logic**

* `0x01` → call `MarketRegistry.resolve(...)` (not `PredictionMarket.onReport`)
* `0x03` → call `ChannelSettlement.submitCheckpointFromPayload(...)`

---

### 4.5 `ReceiverTemplate.sol` — lock configuration

Your pattern is good, but you must enforce:

* config setters only callable by admin
* forwarder/workflow identity is pinned in production (no loose mode)

---

## 5) What to DELETE (or isolate as legacy)

### Delete / isolate strongly

* “Main path” dependency on:

  * `PredictionMarket.claim()` payouts
  * `SessionFinalizer.finalizeSession()` payouts
  * fixed `TOKEN_ADDRESS` constant usage
  * `Treasury` as a custody layer (superseded by vault)

**Decision rule**

* If a contract moves user funds **without going through CollateralVault**, it should be **legacy-only**.

---

## 6) What to INTEGRATE (new execution layer, but minimal now)

Even if Yellow isn’t built yet, you should create the **interfaces** now so you don’t redesign later.

### 6.1 `CollateralVault.sol` (multi-asset)

**Must support**

* per-asset balances
* only authorized settlement contract can apply signed deltas
* prevent withdrawing locked funds
* emit events for all balance changes

### 6.2 `ExecutionLedger.sol`

**Must support**

* positions per market/outcome
* only settlement can apply deltas
* freeze after market resolved

### 6.3 `ChannelSettlement.sol`

**Must support**

* checkpoint nonce monotonicity
* challenge window
* signature verification (operator + users OR operator + committee; start simple)
* fee enforcement callout to FeeManager
* must bind settlement to market lifecycle (no checkpoint after freeze/resolution)

---

## 7) Market lifecycle rules (must be enforceable onchain)

These rules prevent “trade-after-knowledge” and make the system credible for institutions.

1. `OPEN` only between `tradingOpen` and `tradingClose`
2. `FROZEN` after `tradingClose` (anyone can call `freeze`)
3. `RESOLVED` after CRE resolve
4. settlement checkpoints must satisfy:

   * `checkpoint.lastTradeAt <= tradingClose`
   * checkpoint can still be finalized after close, but cannot include trades after close
5. after `RESOLVED`, ledger changes are blocked; only `redeem` allowed

---

## 8) Deliverables (what you should implement first)

### Phase 1 (creation pipeline + safety)

* [ ] `MarketDraftRegistry`
* [ ] `DraftClaimManager`
* [ ] `CREPublishReceiver`
* [ ] `MarketPolicy`
* [ ] modify `MarketFactory` to `createFromDraft`
* [ ] tighten `SettlementRouter` + access controls
* [ ] keep trading onchain legacy for now (optional)

### Phase 2 (fees + treasury)

* [ ] `FeeManager` with caps
* [ ] `FeePool` + `TreasuryPool`
* [ ] enforce fee at settlement/redeem boundary

### Phase 3 (Yellow-ready execution)

* [ ] `CollateralVault` (multi-asset)
* [ ] `ExecutionLedger`
* [ ] `ChannelSettlement` checkpoint logic

### Phase 4 (CCIP + multi-chain)

* [ ] `CCIPGateway` for market status replication + settlement root transport
* [ ] hub-and-spoke collateral model

---

## 9) Summary of “what changes where”

### Keep (but rewire)

* ReceiverTemplate (keep)
* CREReceiver/OracleCoordinator (keep)
* MarketFactory (keep, but change behavior)

### Move out of main path

* PredictionMarket (legacy)
* SessionFinalizer (legacy)

### New canonical path

* Draft registry + claim manager + CRE publish receiver + policy
* MarketRegistry + vault + ledger + settlement + fee manager + treasury

---

If you want the next step: **upload your Solidity files** (or paste key ones) and I’ll produce a second doc that is *line-level*:

* “delete function X”, “rename event Y”, “replace TOKEN_ADDRESS with asset param”,
* plus exact interface signatures and storage migration notes.


# REASONS:

Got it. You want a **curated “market supply pipeline”** where:

* **AI/API** generates *draft markets* offchain (question + type + outcomes + settlement source of truth).
* Users can **claim a draft** to become the market’s **creator/MM** (but they can’t publish arbitrary markets).
* Claiming triggers a **Chainlink CRE workflow** that posts a payload to your contract, and the contract **creates the market exactly** as drafted.
* Creators can later **rebalance their exposure/liquidity** on the market they created (like XO’s “liquidity rebalancing” concept—realigning distribution to current odds). ([Medium][1])

Below is an architecture that’s “senior smart contract engineer” clean: minimal trust, clear invariants, and it won’t fight your future Yellow + CCIP + multi-asset goals.

---

# 1) Core idea: make “draft → claim → publish” an onchain state machine

## Contracts (creation/supply side)

### A. `MarketDraftRegistry` (curation inventory, *not a market*)

Stores an immutable record that a draft exists **without needing to store the entire question string onchain**.

**Draft fields (hash-friendly):**

* `draftId = keccak256(abi.encode(draft))`
* `questionHash` (or `questionURI` to IPFS/Arweave)
* `marketType` (binary/categorical/timeline/pulse/etc.)
* `outcomesHash` (or outcomes URI)
* `resolveSpecHash` (how it resolves + sources of truth)
* `tradingOpen`, `tradingClose`, `resolveTime`
* `collateralPolicyId` (what assets allowed, min deposit, etc.)
* `riskPolicyId` (caps, creator requirements)
* `status`: `PROPOSED → CLAIMED → PUBLISHED → EXPIRED/CANCELLED`

**Who can add drafts?**

* only `AI_ORACLE_ROLE` (your backend signer) OR your owner.
* optionally also allow “community submissions” but those go into `PENDING_REVIEW` (separate queue).

Why? This enforces “not everything can be market”.

### B. `DraftClaimManager` (turn a user into a controlled “Market Maker”)

When a user claims a draft, they become the **creator/MM-of-record** and must put down a **bond** (spam + accountability).

**Claim fields**

* `draftId`, `claimer`, `seedLiquidityCommitment`, `bondAmount`, `expiry`
* `claimerSig` (EIP-712) binding them to the exact draft + terms
* State: `UNCLAIMED/CLAIMED`

**Important:** Claiming does **not** publish a market directly. It triggers CRE publication.

### C. `CREPublishReceiver` (CRE entrypoint → creates market)

This is the contract called by Chainlink Forwarder/CRE. It receives the publish payload:

* `draftId`
* `claimer`
* `publishParams` (the canonical draft params OR a hash+URI)
* `claimerSig`
* `creMetadata` (workflow id / author / etc.)

It verifies:

1. The call came from the trusted forwarder/workflow (your `ReceiverTemplate` pattern)
2. `draftId` exists and is `CLAIMED`
3. `claimerSig` matches the claimant and binds to `draftId + params + chainId`
4. Policy checks pass (`MarketPolicy` module)
5. Draft not expired/cancelled
6. Then calls `MarketFactory.createFromDraft(...)`

### D. `MarketFactory` (creates `MarketRegistry` market instances)

`MarketFactory` becomes the only place that can “mint” a new market record in `MarketRegistry`.

It:

* creates market in `MarketRegistry` with the exact type/outcomes/times
* records `creator = claimer`
* wires “creator privileges” (rebalancing permission, creator fee share, etc.)
* marks draft as `PUBLISHED` (one-way)

---

# 2) Policy layer: how you keep it curated + institutional-friendly

You need a contract that enforces “allowed markets” without being a bottleneck.

### `MarketPolicy` (rules engine)

This is the gatekeeper called by `CREPublishReceiver`/`MarketFactory`.

Checks:

* **Allowed market types** (binary/categorical/timeline/pulse)
* **Allowed resolution specs** (e.g., only certain feeds/APIs/oracles)
* **Topic/category allowlist** (or denylist)
* **Min resolve time** / max duration
* **Min seed** from creator/MM (so no empty markets)
* **Rate limits** per user / per category (anti-spam)
* **Max outcomes** to bound complexity
* **Jurisdiction flags** (optional if you want future compliance segmentation)

Owner can update policies, but **policy updates shouldn’t change existing markets** (immutability matters for trust).

This is similar in spirit to XO’s “market format constraints” (open creation, but within a defined structure like pulse timing windows + lock phase). ([Medium][2])

---

# 3) Creator/MM rebalancing: translate XO’s concept into your system

XO’s “liquidity rebalancing” is basically: creator **sells some exposure** and **redistributes** into other outcomes at current prices, producing a “rebalance ratio” (swap-rate-like) preview. ([Medium][1])

In **your architecture**, since trading is going to Yellow:

### Correct design: rebalancing is just a **specialized trade** inside the Yellow engine

* Creator can submit `RebalanceIntent` (EIP-712):

  * `marketId`
  * `fromOutcome[]`, `sellShares[]`
  * `toOutcome[]`, `buyWeights[]`
  * `minReceived[]` / slippage bounds
  * `deadline`
* Yellow executes it like any trade (updates positions, cash deltas, fees)
* Onchain only sees it in the **final settlement checkpoint**.

**Onchain guardrails you still want:**

* only market creator can use `creatorRebalanceNonce` (prevents others spoofing)
* enforce rebalancing only while market is `OPEN` (no rebalancing after freeze)
* enforce limits from policy (max rebalance frequency, max % of seed per day, etc.)

If you also keep a pool-based legacy AMM path, then implement `CreatorRebalanceModule` there, but for your main path (offchain engine) keep it as “trade semantics” rather than a bespoke onchain swap.

---

# 4) Fees + Treasury in this pipeline

You already picked the best enforcement point: **fees enforced at settlement**.

Here’s how it maps cleanly:

### A. `FeeManager`

* `protocolFeeBps` with hard cap `MAX_PROTOCOL_FEE_BPS`
* optional `creatorFeeBps` (also capped)
* optional `referrerFeeBps` (also capped)
* `MAX_TOTAL_BPS` cap to prevent fee stacking abuse

### B. `FeePool` vs `TreasuryPool` separation

* `FeePool`: receives fees, tracks accounting per-asset
* `TreasuryPool`: protocol treasury, can be funded from FeePool on schedule / governance rule, and used for incentives / grants / “future market funding”

Keep it explicit:

* settlement sends fees → `FeePool`
* `FeePool.sweepToTreasury(amount, asset)` by governance rule

Don’t blur “insurance fund” until you have a real bad-debt model.

---

# 5) Multi-chain + multi-asset reality: how to do this without tearing up your core later

You said: “user deposits can be from any chain and market can be made in any chain (NOT SPECIFIC 1 asset).”

Smart-contract implication: you need **two separations**:

### A) `CollateralVault` must be multi-asset

Balances are `balance[asset][user]`. Each market declares its settlement asset or allowed asset set.

### B) CCIP should replicate **facts**, not trading state

Use CCIP to move:

* draft publication events (optional)
* market lifecycle state: `OPEN/FROZEN/RESOLVED`
* settlement roots/checkpoints (if settlement happens elsewhere)
* payout instructions (if custody is hubbed)

If you want the cleanest MVP:

* choose one “hub chain” for custody, and let other chains host market UIs/mirrors.
* later move to per-chain vaults + cross-chain netting (harder).

---

# 6) The full flow (end-to-end, with your “claim list” UX)

1. **AI generates drafts offchain**

   * produces list of `(draftId, question, type, outcomes, resolveSpec, times, policyId)`
   * publishes to `MarketDraftRegistry` (or posts hash + URI)

2. **User claims a draft**

   * calls `DraftClaimManager.claim(draftId, bond, seedCommitment, sig)`
   * draft becomes `CLAIMED(claimer)`

3. **CRE publishes onchain**

   * workflow consumes claim event, pulls full draft data from your API/DB/IPFS, validates policy again, then calls `CREPublishReceiver.onReport(...)`
   * receiver validates forwarder + claimant signature + policy
   * calls `MarketFactory.createFromDraft(...)`
   * draft becomes `PUBLISHED(marketId)`

4. **Trading**

   * Yellow session opens for `marketId`
   * creator can rebalance as a “rebalance intent trade”
   * settlement checkpoint finalized onchain later

5. **Resolution**

   * CRE resolves from the draft’s `resolveSpec` (your “source of truth” rule)
   * updates `MarketRegistry.resolve(marketId, outcome, confidence)`

6. **Redeem**

   * user redeems from vault/ledger

This is essentially the “structured lifecycle” approach XO highlights (explicit phases like trade → lock/observation → settle) but generalized to your market supply pipeline. ([Medium][2])

---

# 7) Contract architecture summary

**Creation / curation**

* `MarketDraftRegistry`
* `DraftClaimManager`
* `CREPublishReceiver`
* `MarketPolicy`
* `MarketFactory`
* `MarketRegistry`

**Trading settlement**

* `ChannelSettlement` (later, Yellow)
* `ExecutionLedger`
* `CollateralVault`

**Fees / treasury**

* `FeeManager` (caps)
* `FeePool`
* `TreasuryPool`

**Cross-chain**

* `CCIPGateway` (facts + status replication)

---

If you want, I can turn the above into:

* exact Solidity interfaces (`IMarketDraftRegistry`, `IDraftClaimManager`, `IMarketPolicy`, `IMarketFactory`)
* the EIP-712 typed data for `Claim` and `Publish` (to prevent payload tampering)
* and a minimal storage layout that won’t brick you when you add Yellow settlement later.

[1]: https://medium.com/%40xomarket/introducing-liquidity-rebalancing-for-creators-f16bcb785c9c "Introducing Liquidity Rebalancing for Creators | by XO market | Medium"
[2]: https://medium.com/%40xomarket/introducing-pulse-markets-09dfa547d42d "Introducing Pulse Markets. The internet moves in minutes. | by XO market | Jan, 2026 | Medium"


Below is a **smart-contract-only** critique + the cleanest way to refactor ShadowPool so you can safely move trading logic to Yellow sessions later **without locking yourself into wrong onchain primitives**.

---

## 0) First: is your current onchain direction “correct enough” to move to Yellow?

Yes **if** you tighten these invariants now:

### Must-fix invariants before Yellow

1. **Market freeze boundary is enforceable onchain**

* Yellow must not be able to finalize a session that includes trades after `tradingCloseTime`.
* Onchain must verify: `checkpoint.lastTradeAt <= market.tradingCloseTime` (or “checkpoint posted before freeze”).

2. **Nonces are monotonic per (marketId, sessionId)**

* You already have this idea. Make it strict: `nonce == lastNonce + 1` (or `> lastNonce` if you allow skips).
* If you allow `>` you *must* defend against withholding intermediate states.

3. **Settlement is the only source of truth for fees**

* Yellow can *account* fees, but onchain must *enforce* them (your Option 2 is correct).

4. **Custody is centralized into one vault**

* Good: `CollateralVault` as the only place that can move funds.

If these are enforced, you can safely start Yellow trading logic without redesigning custody/settlement later.

---

## 1) What to fix in your current “ShadowPool path” to be exact

### A) Your “SessionFinalizer style payout” is not the right primitive for a trading engine

`SessionFinalizer` pays balances directly. That’s okay for a demo, but for a real trading engine you want:

* **Vault holds funds**
* **Ledger tracks positions**
* **Settlement applies deltas**
* **Redeem pays only after outcome resolution**

So your move to **CollateralVault + ExecutionLedger + ChannelSettlement** is the correct evolution.

### B) ExecutionLedger must become outcome-aware and resolution-aware

Right now you describe:

* `positionOf(user, marketId, outcomeIndex)` and deltas

But you also need **two distinct accounting domains**:

* **Trading-time**: shares/cash deltas (PnL not final yet)
* **Post-resolution**: claimable payout (depends on winning outcome)

So ExecutionLedger should store *either*:

* `shares[user][marketId][outcome]` + `cash[user][marketId]`, or
* a single “portfolio vector” per user per market (compressed root) with proofs.

If you want simple MVP: store explicit shares per outcome. (Gas cost OK at small scale; later move to Merkle proof settlement.)

### C) ChannelSettlement must defend against “operator censorship”

If only operator can submit checkpoints, you need one of:

* **User escape hatch**: user can submit the latest signed state they have (optimistic).
* Or “challenge mode”: if operator posts a worse state, user can challenge with a better signed state before deadline.

Otherwise institutions will call it custodial risk.

---

## 2) Clean contract split: what belongs where (creation vs settlement vs fees vs treasury)

Here is the split that stays sane as you add Yellow, CRE, Datafeeds, CCIP.

### 2.1 Market creation & lifecycle

**`MarketRegistry`** (creation + market rules, *no funds movement*)

* Stores: marketType, outcomes/windows, `tradingOpen`, `tradingClose`, `resolveTime`, status.
* Functions:

  * `createMarket(params)` (direct)
  * `createMarketFromCRE(params)` (CRE path)
  * `freeze(marketId)` (permissionless when `block.timestamp >= tradingClose`)
  * `resolve(marketId, outcome, confidence, evidenceRef)` (only Oracle/Router)
* Emits canonical events consumed by offchain.

✅ This contract should **not** calculate trading prices (you already align with “no onchain LS-LMSR”).

### 2.2 Custody

**`CollateralVault`** (custody + withdrawals + escrow rules)

* `deposit(asset, amount, receiver)`
* `withdraw(asset, amount, receiver)`
* `lock(user, marketId, sessionId, amount)` (optional if you isolate risk)
* `applyCashDelta(user, asset, delta)` (only Settlement)
* `pay(user, asset, amount)` (only MarketRegistry redeem / Settlement)

**Key design for “not specific 1 asset”:**

* Vault must support **multiple ERC20 assets** and keep balances per asset.
* Use `mapping(asset => mapping(user => uint256))`.

### 2.3 Settlement (Yellow finality)

**`ChannelSettlement`** (ONLY verifies state + applies deltas; no market creation)

* Accepts signed checkpoint:

  * `checkpoint = {marketId, sessionId, nonce, lastTradeAt, stateRoot, deltasRoot, feeRoot}`
* Challenge window:

  * `submitCheckpoint`
  * `challengeCheckpoint` (submit higher nonce / better state with sigs)
  * `finalizeCheckpoint`
* On finalize:

  * Calls `ExecutionLedger.applyDeltas(...)`
  * Calls `CollateralVault.applyCashDeltas(...)`
  * Calls `FeeManager.collectFees(...)`

### 2.4 Fees

**`FeeManager`** (policy + caps + distribution)

* Stores:

  * `protocolFeeBps` (settlement or trading)
  * `creatorFeeBps` (optional)
  * `referrerFeeBps` (optional)
  * `MAX_PROTOCOL_FEE_BPS` (hard-coded constant)
* Rules:

  * `require(protocolFeeBps <= MAX_PROTOCOL_FEE_BPS)`
  * optionally also `protocolFeeBps + creatorFeeBps + referrerFeeBps <= MAX_TOTAL_BPS`
* Only **owner/governance** can set within caps.

**Where to take fee (your Option 2):**

* In `ChannelSettlement.finalizeCheckpoint` (or `CollateralVault.redeem`)
* Fee is computed from realized positive PnL or from notional volume included in checkpoint.
* **Do not trust the operator’s fee numbers**—recompute from deltas / positions.

This matches how serious systems keep fees enforceable in settlement, even if execution is offchain. (Also aligns with known tradeoffs: LMSR/LS-LMSR onchain is expensive; moving pricing offchain is common because complex scoring-rule computation is costly onchain. )

### 2.5 Treasury pool (insurance + growth fund)

**`TreasuryPool`** (protocol-owned funds)

* Receives:

  * protocol fees
  * optional “market creation fees”
* Can pay:

  * “loss coverage” only through explicit governance-controlled functions
* Must have strict authorization + accounting (events for every spend).

**Important:** “cover loss” needs a defined meaning. If your system is fully collateralized, there shouldn’t be loss *unless*:

* oracle error / rollback / dispute payout
* bug bounties / refunds
* bad debt due to margin-like design (you likely don’t want margin in MVP)

So keep it as:

* **fee revenue vault + discretionary spend** (governed), not as a magical auto-insurance.

---

## 3) Fee model you should implement first (smart-contract perspective)

For MVP with Yellow trading:

### Best first fee: **Settlement fee on positive realized PnL**

Why:

* easy to enforce
* hard to game
* low calldata (no per-trade logs needed)

Mechanism:

* During finalize, you know each user’s **net cash delta** for the session (profit/loss).
* If `profit > 0`: `fee = profit * protocolFeeBps / 10_000`
* Deduct fee from payout/credit.
* Transfer fee to `TreasuryPool`.

This is the least controversial for institutions.

Later you can add:

* volume fee (requires volume accounting in checkpoint)
* maker/taker fees (requires order-flow metadata)

---

## 4) How to make “multi-chain deposit + markets on any chain” possible (without breaking custody)

Smart-contract reality check: if users deposit on Chain A but market settles on Chain B, you must choose a topology.

### The only clean topology for MVP institutions: **Hub-and-spoke collateral**

* One “Collateral Hub Chain” where `CollateralVault` is canonical.
* Other chains host “MarketRegistry mirrors” + execution UX.
* Settlement roots / outcomes are transported via CCIP to the hub for custody changes.

If you try “every chain has its own vault” you get fragmented liquidity + difficult reconciliation.

So implement:
**`CCIPGateway`** (onchain adapter)

* Receives CCIP messages:

  * `MarketCreated`, `MarketFrozen`, `MarketResolved`
  * `CheckpointFinalizedRoot` (or “net deltas”) from satellite chain
* Sends CCIP messages out similarly.

**Key rule:**

* CCIP updates **onchain state**, not Yellow.

---

## 5) Datafeeds placement (what should be onchain vs offchain)

If you support multi-asset collateral, you need enforceable valuations:

* For settlement-time conversions, margin checks, or risk caps, you want deterministic values.
* That implies reading feeds onchain (or committing feed snapshot via CRE).

Also note that scoring-rule AMMs like LMSR/LS-LMSR have known implementation complexity/cost concerns onchain; many systems move heavy computation offchain and keep only enforcement onchain. 

---

## 6) What institutions will care about (contract-level)

If you want institutions, your contracts must show:

1. **Clear finality rules**

* freeze → resolve → settle → redeem

2. **No hidden discretionary controls**

* Owner can adjust fees but **cannot exceed hard cap**
* Owner cannot seize user funds (vault has no arbitrary transfer)

3. **Dispute and exit path**

* user can always exit with latest signed state (or challenge malicious checkpoint)

4. **Auditability**

* events for checkpoint submitted/challenged/finalized
* store which checkpoint root was used for a user’s payout

Institutions tend to prefer well-understood market mechanisms (order books/CLOB) when liquidity is present, but prediction markets often have thin liquidity and use automated mechanisms to guarantee continuous quoting. 
Your approach (offchain execution + onchain enforceable settlement) is basically the “institutional pattern” used by serious venues: fast matching offchain, custody/settlement onchain.

---

## 7) Concrete “next changes” checklist (smart contracts only)

### Must do now (before Yellow engine)

* [ ] Add `MarketRegistry.freeze()` and enforce in settlement: checkpoint must respect `tradingCloseTime`
* [ ] Add `lastTradeAt` (or “stateTimestamp”) to checkpoint and verify it
* [ ] Implement `FeeManager` with hard caps (`MAX_PROTOCOL_FEE_BPS`)
* [ ] Implement `TreasuryPool` + route all fees there
* [ ] Change settlement flow: finalize → apply deltas → fees → vault updates (never direct payout from settlement contract)
* [ ] Add user challenge / escape hatch to ChannelSettlement

### Can do later

* [ ] CCIPGateway + hub/spoke settlement
* [ ] Multi-collateral valuation (Datafeeds)
* [ ] Merkleized deltas (scale)
* [ ] Creator/referrer fee splits

---

If you paste your **actual Solidity files** (or upload the repo / key contracts), I’ll go line-by-line and point out: missing access controls, reentrancy surfaces, nonce/challenge bugs, fee bypasses, and how to implement the fee cap + treasury routing cleanly with minimal gas.
