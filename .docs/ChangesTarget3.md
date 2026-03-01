You’re in a really good place now: **tests pass, the LP vault is the counterparty, and fee-splitting exists**. After this point the “next work” is mostly about **hardening the economics + preventing edge-case bypasses**, then **shipping an MVP deployment pipeline**.

Here’s the exact next checklist I’d do as the protocol engineer on this repo, in priority order.

---

# 1) Lock the critical “seeded LP exists” invariant (P0.1)

Right now you called out the biggest remaining gap yourself:

* `claimDraft` (no seed) still exists
* publish accepts any “claimed” draft
* seed lock is metadata-only

That means a market can be published **without an LP vault bound**, and then your net-flow step is skipped → your system becomes “trader ledger with no counterparty”, which is the solvency footgun.

## What to do next

### A. Make “seeded claim required” for curated publish

In `CREPublishReceiver` (or inside `MarketFactory.createFromDraft`) enforce:

* `DraftClaimManager.vaultByDraft[draftId] != address(0)`
* `DraftClaimManager.seedAmountByDraft[draftId] >= draft.minSeed`
* optional: `LiquidityVault4626.totalSupply() > 0`

**Outcome:** curated markets *cannot* go live without LP capital.

### B. Deprecate or gate `claimDraft`

You don’t have to delete it yet. But:

* either require only a role can call legacy claim, or
* publish rejects drafts claimed via legacy path

**Minimal version:** add `claimType[draftId] = SEEDED | LEGACY` and enforce SEEDED for publish.

---

# 2) Enforce seed share lock at token level (P0.2)

You currently track:

* `seedSharesLocked`, `seedUnlockTime` (metadata)
  but shares are minted to the claimer wallet and can be transferred away.

That breaks your “market maker stays MM until close” safety.

## Two clean solutions

### Option 1 (best UX): mint seed shares into a locker contract

* `DraftClaimManager` deposits seed and mints shares to `SeedLocker`
* locker holds shares until `unlockTime`
* locker can delegate voting/ownership to creator if needed

### Option 2 (cheap): add transfer restriction inside LiquidityVault4626

Override ERC20 `_update` / `_beforeTokenTransfer` and block transfers of “locked shares” for an address until unlock.

But because ERC-4626 shares are normal ERC-20, **locker is safer** and keeps vault standard.

**What to implement now:** `SeedLocker` (simple escrow).

---

# 3) Make LP fee routing correct when LP supply is 0 (P0.3)

You already have logic:

> “lp fee -> LP vault donation if LP shares exist, else fallback to treasury”

That’s directionally correct, but make it explicit and test it.

## Do next

* In `ChannelSettlement.finalizeCheckpoint`, before donating lpFee:

  * if `vault == address(0)` → route lpFee to `FeePool` or `TreasuryPool`
  * else if `LiquidityVault4626.totalSupply() == 0` → route to treasury (or revert publish earlier so this never happens)
* Add test: “lpFee with no LP supply goes to protocol”

But if you implement step #1 correctly, this path should almost never trigger (because seeded publish guarantees supply > 0).

---

# 4) Add the one invariant test you still need: “solvency net-flow must always run” (P0.4)

You already do net-flow “if liquidity vault exists”. That’s dangerous if any market can exist without vault binding.

After step #1, curated markets always have a vault; still, I’d harden.

## Change

In `ChannelSettlement.finalizeCheckpoint`:

* if market is in execution lane and uses fee splitting, require `liquidityVault != 0` (or if missing, revert)
* OR add market flag `usesLpVault` in MarketRegistry and enforce that.

## Add tests

* if liquidity vault is missing → finalizeCheckpoint reverts
* prevents silent solvency bypass

---

# 5) Fix remaining “event correctness” for ops / debugging (P0.5)

You noted:

* `SettlementRouter.finalizeSession` emits placeholder `MarketSettled(...)`

This will hurt you in hackathon demos and real ops.

## Do next

Add a dedicated event:

```solidity
event SessionPayloadRouted(
  address indexed target,
  bytes32 indexed payloadHash,
  uint256 indexed marketId,
  bytes32 sessionId
);
```

Even if you can’t decode `marketId/sessionId` from payload reliably, emit:

* target
* payloadHash
* and maybe `routeType` enum

This makes tracing + Tenderly debugging way easier.

---

# 6) Decide one production lane and freeze the rest (P1 “ship mode”)

Right now you have 3 lanes. For shipping, pick **one** as “main”:

✅ **Curated + execution lane** should be main
🟨 Legacy pool stays as demo-only

## Do next

* Put a README “Production Mode” section:

  * curated publish required
  * legacy pool is demo
* In deploy scripts: deploy only curated/execution stack
* Leave legacy in repo but not wired in deploy config

---

# 7) Deployment playbook (what you do after code)

You’re basically ready to deploy a testnet MVP.

## Minimal deployment order

1. Deploy TradingVault: `MultiAssetVault(channelSettlement=temp)`
2. Deploy `ExecutionLedger(channelSettlement=temp)`
3. Deploy `MarketRegistry(vault=MAV, ledger=EL)`
4. Deploy `FeePool`, `TreasuryPool`, `FeeManager`
5. Deploy `ChannelSettlement(vault=MAV, ledger=EL, operator=OP)` + set pointers to registry, fee manager, fee pool
6. Wire back:

   * `MAV.setChannelSettlement(ChannelSettlement)`
   * `MAV.setMarketRegistry(MarketRegistry)`
   * `ExecutionLedger.setChannelSettlement(ChannelSettlement)`
7. Deploy curated:

   * `MarketDraftBoard`, `MarketPolicy`, `LiquidityVaultFactory`, `DraftClaimManager`
   * set roles: AI_ORACLE_ROLE, PUBLISH_CALLER_ROLE
8. Deploy `MarketFactory` and configure:

   * approvedPublishReceivers
   * draftBoard/claimManager addresses
9. Deploy oracle route:

   * `SettlementRouter` (set channelSettlement)
   * `OracleCoordinator` (set settlementRouter, reportValidator)
   * `CREReceiver` (set oracleCoordinator, receiverTemplate forwarder gates)
10. Configure forwarder allowlists in ReceiverTemplate or each receiver

Then run a scripted scenario:

* proposeDraft → claimAndSeed → publish → submitCheckpoint → finalizeCheckpoint → resolve → redeem

---

# 8) What to postpone (don’t touch yet)

You listed the big “future” modules. Correct to postpone:

* ResolutionManager (bond/evidence/challenge)
* checkpoint transcript v2 (roots)
* risk sentinel
* CCIP

Don’t add them until you’ve shipped the curated + LP vault MVP end-to-end on one chain.

---

# The single best next PR

If you only do one PR next, do this:

### **PR: Enforce seeded publish + hard seed lock**

* Publish must require seeded claim + vault exists
* Mint seed shares into a locker until tradingClose
* Add solvency invariant test (finalize requires vault)
* Add proper session routing event

That closes the last real economic/security holes and makes your system “judge-ready”.

If you want, paste your current `CREPublishReceiver` and `DraftClaimManager` function signatures for `claimAndSeed` + publish payload, and I’ll tell you exactly where to add the 3 publish-time guards and what the `SeedLocker` interface should look like.

Excellent. This is now at the stage where you should think like an external auditor.

Below is a **production-grade audit + testing preparation checklist**, structured exactly how a senior audit team would approach your system.

This is not cosmetic. This is the level you want before mainnet.

---

# 🔐 0. Define Your Core Economic Invariants (Must Be Explicit)

Before technical auditing, you must formalize these as written invariants:

### I1 — Solvency Invariant

For every market:

```
Σ trader net cash + LP vault assets + protocol fees + creator fees = conserved
```

No settlement path can mint or destroy value.

### I2 — No Negative Position Invariant

ExecutionLedger positions must never go negative.

### I3 — Single-Resolution Invariant

A market can be resolved exactly once.

### I4 — Settlement Window Integrity

A checkpoint finalized must:

* have valid signatures
* respect nonce monotonicity
* respect challenge window
* respect tradingClose

### I5 — LP Counterparty Invariant

If market uses LP vault:

* netTraderDelta must always reconcile with LP vault
* settlement cannot skip reconciliation silently

Write these in README as formal invariants.

---

# 🧱 1. Architecture-Level Risk Review

## 1.1 Modular Boundary Review

Ensure:

* No contract both *verifies* and *executes* logic (separation of concerns)
* No circular trust dependencies
* No hidden fallback logic

Specifically check:

* SettlementRouter cannot be bypassed
* OracleCoordinator cannot be bypassed
* CREReceiver cannot call target directly

Add test:

```
attempt resolve directly from external EOA → revert
```

---

# 🧠 2. Oracle Ingress Audit Checklist

## 2.1 ReceiverTemplate

Ensure:

* forwarder cannot be disabled without event
* forwarder address cannot be set to zero silently
* workflow metadata validation cannot be bypassed

Add tests:

* invalid sender
* wrong workflow id
* malformed report payload

---

## 2.2 OracleCoordinator

Check:

* only creReceiver can call submitResult/submitSession
* confidence validation revert path tested
* confidence edge cases (0, max uint16)

Add:

* fuzz test confidence bounds

---

## 2.3 SettlementRouter

Critical:

* useReceiverAllowlist enabled in production?
* fallback to SessionFinalizer must not activate unintentionally

Add:

* test route when channelSettlement = 0
* test allowlist disabled/enabled behavior

---

# 🏦 3. Liquidity Vault & Solvency Audit

This is your highest financial risk zone.

---

## 3.1 MultiAssetVault

Audit points:

* Can freeBalance ever underflow?
* Can lockedBalance ever underflow?
* Can applyCashDeltas cause imbalance across users?
* Can redeemPayout drain vault for wrong asset?

Add tests:

* fuzz cashDeltas with mixed signs
* simulate malicious delta ordering
* simulate negative netTraderDelta edge case

Critical check:

```
Σ freeBalance(asset) must equal vault ERC20 balance - locked aggregate
```

Add invariant test for this.

---

## 3.2 LiquidityVault4626

Check:

* payToTradingLedger callable only by ChannelSettlement
* totalAssets reflects actual ERC20 balance
* no rounding exploit from ERC-4626 deposit/withdraw edge cases
* cannot reenter via ERC20 callback

Add:

* reentrancy test via malicious ERC20 mock

---

## 3.3 LP Net Flow Settlement

In ChannelSettlement:

You must verify:

* netTraderDelta logic handles:

  * all positive
  * all negative
  * mixed
  * zero

* LP vault transfer order:

  * LP → TradingVault (if net > 0)
  * TradingVault → LP (if net < 0)

Add tests:

* scenario where traders win large amount
* scenario where traders lose large amount
* scenario LP vault insufficient liquidity → should revert

---

# 🧾 4. Fee Splitting Audit

Your FeeManager is now part of protocol revenue logic.

Audit:

* fee cap enforced (2%)
* split math sum correctness:

```
protocol + lp + creator + net = original profit
```

* rounding behavior (dust leakage?)

Add:

* property test for computeSplit with random PnL
* ensure no overflow with max int128

Check:

* protocol fee always routed to FeePool
* lpFee only routed if vault exists and supply > 0
* creatorFee cannot exceed profit

---

# 🧠 5. Checkpoint Security Audit (Most Complex Surface)

ChannelSettlement is your attack surface.

---

## 5.1 Signature Validation

Ensure:

* duplicate signer rejection
* missing signer rejection
* replay protection across markets
* replay protection across sessionId
* EIP-712 domain separation correct (chainId included?)

Add:

* replay attack test
* cross-market signature replay test
* fuzz test of delta list order

---

## 5.2 Nonce + Challenge

Check:

* challenge replaces pending correctly
* old pending cannot finalize after challenge
* finalize clears pending

Add:

* race condition tests
* submit A → challenge B → finalize A must fail

---

## 5.3 Timing

Check:

* validAfter/validBefore logic strictly enforced
* lastTradeAt <= tradingClose enforced

Add:

* test boundary equality conditions
* test finalize at exact challengeDeadline

---

# 🧮 6. Ledger + Position Invariants

ExecutionLedger:

Audit:

* int256 arithmetic safety
* no overflow on sharesDelta
* negative position revert always triggered

Add:

* fuzz random deltas with constraint that sum positive
* assert no negative position across 1000 random tests

---

# 🧾 7. Curated Pipeline Audit

This is governance risk.

---

## 7.1 DraftClaimManager

Critical:

* claimAndSeed cannot be front-run to steal draft
* signature includes:

  * draftId
  * asset
  * seed
  * deadline
  * claimer address
* replay attack impossible

Add:

* replay test
* claim with modified seed test
* claim with wrong asset test

---

## 7.2 Publish Flow

Must verify:

* publish requires claimed draft
* publish requires seeded vault (if policy)
* publish binds liquidityVault to registry
* cannot publish twice

Add:

* double publish test
* publish expired draft test
* publish after cancel test

---

# 🏛 8. MarketRegistry Audit

Check:

* resolve callable only by router
* cannot resolve twice
* redeem only once
* redeem only winning outcome
* settlementAsset consistent

Add:

* redeem before resolve test
* redeem twice test
* redeem losing position test

---

# 🔒 9. Access Control Audit

Create a table:

For each contract:

* list onlyOwner
* list role-based
* list setter functions

Check:

* no critical setter missing access control
* no public setter on vault addresses
* no unguarded emergency bypass

Add:

* static analysis: Slither access control check

---

# 🛡 10. Reentrancy & ERC20 Edge Cases

You use SafeERC20 but still:

Check:

* any external call before state mutation?
* vault transfers before internal accounting?
* reentrancy guard needed on settlement?

Add:

* malicious ERC20 mock with reenter attempt
* test finalizeCheckpoint with malicious token

---

# 🧪 11. Fuzz Testing Requirements

Minimum fuzz suite:

* random checkpoint delta arrays
* random market creation parameters
* random fee split configs
* random LP net delta flows
* random share reduce/add in PoolMarketLegacy

Use:

```
forge test --fuzz-runs 10000
```

---

# 📉 12. Economic Attack Simulation

Simulate:

1. Trader colludes with operator to craft extreme deltas.
2. LP withdraws right before large loss checkpoint.
3. Market resolves immediately after challenge window.
4. No LP vault exists scenario.

Write scenario tests.

---

# 🔭 13. Gas & DoS Review

Check:

* MAX_DELTAS cap enforced
* MAX_USERS cap enforced
* loops bounded
* cannot create gas grief attack with large user arrays

Add:

* test max boundary values

---

# 🧩 14. Integration Surface Review

Verify:

* MarketFactory cannot bind wrong vault
* settlementAsset immutable after creation?
* liquidityVaultByMarketId cannot be overwritten

Add:

* test attempt to overwrite vault

---

# 🏁 15. Production Hardening Checklist

Before mainnet:

### Must Do:

* enforce seeded publish
* enforce vault required for execution markets
* hard-lock seed shares
* remove legacy publish path or disable
* enable allowlist in SettlementRouter

### Should Do:

* add dedicated SessionRouted event
* freeze upgrade setters (optional renounceOwnership or timelock)

---

# 🛠 16. External Tooling You Should Run

Before audit:

* Slither
* Echidna property tests
* MythX or Medusa
* forge coverage
* gas snapshot

---

# 🧾 17. Documentation for Auditors

Provide:

* Architecture diagram
* Invariant list (section 0)
* Economic model explanation
* Trust boundary explanation
* Known limitations section (honest)

Auditors love clarity.

---

# 🚨 Final Risk Zones (Where Real Bugs Will Hide)

1. netTraderDelta reconciliation
2. fee split rounding edge cases
3. seed not actually locked
4. publish without vault binding
5. signature replay cross-market
6. MultiAssetVault asset mismatch
7. challenge window race condition

If those are airtight, your protocol is structurally strong.

---

# 📌 What Production-Grade Means For You

To be production-grade, your system must:

* Enforce solvency invariant at all times
* Make LP mandatory for execution markets
* Prevent economic bypass via legacy path
* Have fuzz coverage for checkpoint engine
* Have invariant tests for vault balances

You are close. But you need:

* 2–3 more invariant test suites
* seed hard-lock enforcement
* vault-required publish enforcement
* fuzz/property tests

---

If you want next step:

Tell me:

* Are you targeting testnet first?
* Single chain?
* Planning public audit?

Then I’ll give you a prioritized “next 4 weeks security roadmap” tailored to your launch timeline.
