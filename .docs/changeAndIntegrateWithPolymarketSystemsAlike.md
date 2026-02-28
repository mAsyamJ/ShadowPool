Analyze deeply:

[1]: https://docs.polymarket.com/trading/orders/overview?utm_source=chatgpt.com "Overview - Polymarket Documentation"
[2]: https://docs.polymarket.com/trading/ctf/overview?utm_source=chatgpt.com "Conditional Token Framework"
[3]: https://docs.polymarket.com/concepts/resolution?utm_source=chatgpt.com "Resolution"

Perfect — now I will give you a **FULL MIGRATION + IMPLEMENTATION DOCUMENT** exactly like a protocol internal spec or audit-ready engineering RFC.

This is NOT just ideas.

This is:

✅ Before → After architecture
✅ Exact invariants changes
✅ Contract responsibilities after migration
✅ Storage additions
✅ Execution flow comparison
✅ Engineering order of implementation
✅ Risks solved vs new risks introduced
✅ Deployment wiring order
✅ Test migration checklist

You can drop this inside:

```
docs/RetroPick-v3-ERC1155-RiskReservation.md
```

and treat it as **engineering source-of-truth**.

---

# RetroPick V3 Migration Specification

## ERC-1155 Outcome Positions + Locked Transfers + LP Risk Reservation

Version: Draft Engineering RFC
Target Network: Avalanche Fuji → Mainnet L1
Compatibility: Nitrolite Yellow + CRE Settlement

---

# PART 1 — Why Change?

## Current Model (V2)

Positions live inside:

```
ExecutionLedger
```

stored as:

```
keccak(user, marketId, outcomeIndex) -> int256 shares
```

Settlement:

```
Checkpoint
→ ChannelSettlement.finalizeCheckpoint
→ ExecutionLedger.applyDeltas
→ Vault cash deltas
→ Redeem reads ledger
```

### Strengths

* Extremely gas efficient.
* Fully batchable.
* Offchain LS-LMSR works well.

### Weaknesses

1. Not composable.

No tokens exist.

Users cannot:

* transfer claims,
* collateralize prediction outcomes,
* use NFTs or lending integrations.

Polymarket uses ERC1155 outcome tokens.

---

2. LP underwriting unsafe.

Currently:

```
LP pays IF vault has money.
```

No exposure bound.

Relayer must behave.

This is NOT protocol-level risk control.

---

3. Ledger is non portable.

Wallets cannot display holdings.

Indexers harder.

---

## Goal

Upgrade to:

```
ERC1155 Outcome Positions
+
Locked Transfers (pre resolution)
+
Risk Reservation Underwriting
```

WITHOUT losing:

* checkpoint settlement
* offchain trading UX
* curated pipeline.

---

# PART 2 — Before vs After Architecture

---

## BEFORE

```
Relayer
 ↓
Checkpoint
 ↓
ChannelSettlement
 ↓
ExecutionLedger (shares)
 ↓
Vault balances
 ↓
Redeem()
```

LP safety:

```
hope vault has funds.
```

---

## AFTER

```
Relayer
 ↓
Checkpoint
 ↓
ChannelSettlement
 ↓
OutcomeToken1155 mint/burn
 ↓
RiskManager reserve capital
 ↓
Vault transfers
 ↓
Redeem burns ERC1155.
```

LP safety:

```
Protocol enforced underwriting cap.
```

---

# PART 3 — NEW CONTRACTS

---

# 3.1 OutcomeToken1155

Replaces ExecutionLedger as canonical ownership.

### Responsibilities

* represent outcome ownership.
* redeemable claim token.

Example:

```
ETH > $4000 YES
```

is a token.

---

## Token ID

```
uint256 tokenId =
(marketId << 32)
|
outcomeIndex;
```

Why?

* deterministic
* cheap decode.

---

## Storage

Add:

```
address public channelSettlement;
address public marketRegistry;
```

---

## Authority

Only settlement mints/burns.

```
mint → onlyChannelSettlement
burn → onlyChannelSettlement
```

Users cannot mint.

---

## Transfer Lock (CRITICAL)

Override:

```
_beforeTokenTransfer
```

Rule:

```
if from != 0 AND to != 0:

require market resolved.
```

Meaning:

### Allowed

Mint:

```
0 → user
```

Burn:

```
user → 0
```

### Forbidden

```
user → user
```

while market open.

---

Why?

Because checkpoint settlement burns shares.

If users transferred tokens mid session:

```
burn would revert.
```

Checkpoint model collapses.

This keeps architecture intact.

---

After resolution:

Transfers unlock.

Claims become tradable assets.

---

# 3.2 MarketRiskManager

Your protocol moat.

---

## Problem solved

Today:

```
netTraderDelta > LP vault balance
```

→ revert.

Bad UX.

No underwriting control.

---

## Solution

Reserve LP payout budget.

---

Storage:

```
mapping(marketId => uint256 cap)
mapping(marketId => uint256 reserved)
```

---

Meaning:

```
cap = max LP payout allowed.
```

---

Example:

LP seed:

```
$50
```

Policy:

```
max exposure multiplier = 3x
```

Cap:

```
150 USDC.
```

---

Checkpoint wants LP to pay:

```
+30.
```

Reserve:

```
reserved +=30.
```

Next checkpoint:

```
+140.
```

Fails.

```
30+140 >150.
```

Protocol stops underwriting.

No relayer trust required.

---

## Interface

```
reserveLpPayout(marketId, amount)
releaseLpPayout(...)
setMaxLpPayout(...)
```

Authority:

```
onlyChannelSettlement reserve.
```

---

# PART 4 — ChannelSettlement Changes

Your pasted function:

```
finalizeCheckpoint()
```

gets three upgrades.

---

## Step 1 — Shares become ERC1155

Replace:

```
LEDGER.applyDeltas(...)
```

with:

```
_applyShareDeltasAs1155(...)
```

Mint:

```
sharesDelta >0
```

Burn:

```
sharesDelta <0
```

---

## Step 2 — Accounting invariant

Add:

```
rawSum == netTraderDelta + totalFees
```

inside `_applyCashDeltasAndFees`.

This detects malformed deltas.

Massive audit improvement.

---

## Step 3 — Risk Reservation

Before LP payment:

Add:

```
riskManager.reserveLpPayout(...)
```

only if:

```
netTraderDelta >0.
```

---

## Step 4 — Explicit solvency check

Add:

```
vaultBalance >= netTraderDelta.
```

Better revert reason.

Better monitoring.

---

# PART 5 — Redeem Changes

Old:

```
ledger.positionOf(...)
```

New:

```
erc1155.balanceOf(...)
```

Then:

```
burn tokens.
```

Then:

```
redeem payout.
```

---

Meaning:

ownership determines payout.

Exactly like Polymarket claims.

---

# PART 6 — Publish Flow Change

Inside:

```
MarketFactory.createFromDraft
```

Add:

```
riskManager.setMaxLpPayout(...)
```

Example:

```
cap = minSeed * exposureMultiplier.
```

Policy driven.

---

# PART 7 — Vault Safety (Phase 2 Optional)

Today LP withdraw freely.

Danger:

LP withdraws after underwriting.

Fix later:

Vault queries:

```
MarketRiskManager.totalReserved()
```

Block withdrawals beyond free assets.

---

Not required first launch.

---

# PART 8 — Removed Components

ExecutionLedger becomes deprecated.

Keep for migration compatibility.

Later:

remove.

---

# PART 9 — Trust Model Improvements

Before:

Relayer must behave.

After:

Protocol enforces:

* payout caps
* accounting invariant
* mint burn correctness.

---

# PART 10 — Deployment Wiring

Order:

Deploy:

```
OutcomeToken1155
MarketRiskManager
```

Then:

```
ChannelSettlement.setOutcomeToken(...)
ChannelSettlement.setRiskManager(...)
```

Then:

```
OutcomeToken.setChannelSettlement(...)
OutcomeToken.setMarketRegistry(...)
```

---

# PART 11 — Test Migration

Add:

### transfer locked

```
transfer before resolution → revert.
```

---

### risk cap

```
reserve > cap → revert.
```

---

### redeem burns

```
redeem removes tokens.
```

---

### accounting invariant

force bad fee math → revert.

---

### LP insolvency

balance < payout → revert.

---

# PART 12 — What You Now Beat Polymarket On

Polymarket:

```
Fully collateralized.
```

Capital inefficient.

---

RetroPick:

```
Shared underwriting.
Risk capped.
Gasless trading.
ERC1155 claims.
```

You scale thousands of markets.

They cannot easily.

---

# PART 13 — Migration Strategy

Recommended:

Phase 1:

```
ERC1155 mint/burn
risk cap
```

Phase 2:

```
vault withdraw restriction.
```

Phase 3:

```
crosschain mirror.
```

---

# PART 14 — Final Result

You now have:

* ERC1155 claims.
* instant offchain fills.
* LP underwriting safety.
* capital efficiency.
* CRE automation.

This is not just a prediction market.

It becomes:

> Programmable Market Infrastructure.

---

# DETAILS:

Perfect — **“lock transfers pre-resolution + add risk reservation”** is the cleanest way to get **Polymarket-like ERC-1155 positions** *without* breaking your checkpoint delta model, and the **risk reservation** is exactly how you become *better than Polymarket* (capital-efficient safety instead of full collateralization everywhere).

Below is an **implementation-ready spec** with exact contract surfaces + patch plan against the functions you pasted.

---

# RetroPick v3 Spec

## ERC-1155 Outcome Tokens (transfer-locked pre-resolution) + Market Risk Reservation

### Design goals

1. Keep your current checkpoint pipeline unchanged: `Delta(sharesDelta, cashDelta)` batch settles.
2. Replace `ExecutionLedger` as the canonical position record with **ERC-1155 outcome tokens**.
3. Prevent delta burns from failing due to user transfers by **locking transfers while market is not Resolved**.
4. Add an on-chain **RiskReservation** layer that:

   * caps LP underwriting per market,
   * reserves capital when LP owes traders,
   * blocks LP withdrawals beyond free assets (optional v1).

---

## 1) New Contract: `OutcomeToken1155.sol`

### Token ID scheme

```solidity
tokenId = (marketId << 32) | uint32(outcomeIndex);
```

### Key rule: transfer locked until market resolved

* Allow mint/burn always.
* Disallow transfers (`from != 0 && to != 0`) unless market is resolved.

### Interface

```solidity
interface IOutcomeToken1155 {
    function id(uint256 marketId, uint32 outcomeIndex) external pure returns (uint256);
    function mint(address to, uint256 marketId, uint32 outcomeIndex, uint256 amount) external;
    function burn(address from, uint256 marketId, uint32 outcomeIndex, uint256 amount) external;

    function setChannelSettlement(address cs) external;
    function setMarketRegistry(address mr) external;
}
```

### Implementation notes

* Use OpenZeppelin ERC1155.
* Store:

  * `address public channelSettlement;`
  * `address public marketRegistry;`
* Add modifiers: `onlyChannelSettlement`, `onlyMarketRegistry` (if you want MR to burn directly; otherwise only CS burns via a callable).

### Transfer lock hook

In `_beforeTokenTransfer` (or OZ v5 `_update` depending on version), for each tokenId:

* decode `(marketId, outcomeIndex)`
* query registry status: `mr.status(marketId) == Resolved`
* if not resolved and it’s a transfer (from != 0 && to != 0), revert.

This is the **minimum** to keep your checkpoint mint/burn model valid.

---

## 2) New Contract: `MarketRiskManager.sol` (Risk reservation)

This contract is the “better than Polymarket” piece.

### What it does

* Define a **max LP payout** per market.
* Track **reserved LP payout** (how much LP is already committed to pay traders).
* Enforce that a new checkpoint that requires LP to pay `netTraderDelta > 0` does not exceed remaining cap.
* Optionally enforce LP vault “free assets” for withdrawals (phase 2).

### Interface

```solidity
interface IMarketRiskManager {
    function setMaxLpPayout(uint256 marketId, uint256 cap) external; // owner or MarketFactory
    function maxLpPayout(uint256 marketId) external view returns (uint256);
    function reservedLpPayout(uint256 marketId) external view returns (uint256);

    function reserveLpPayout(uint256 marketId, uint256 amount) external; // onlyChannelSettlement
    function releaseLpPayout(uint256 marketId, uint256 amount) external; // onlyMarketRegistry (optional)
}
```

### Core rule

When finalizing a checkpoint, if `netTraderDelta > 0`:

* require `reserved + netTraderDelta <= cap`
* then increment `reserved += netTraderDelta`

**Where does `cap` come from?**
You can set it at publish time using policy:

* simplest: `cap = seedAmount * multiple`
* or `cap = fixed cap from MarketPolicy`
* or `cap = min(seed, X% of vault TVL at publish)`

Start simple and configurable; you can evolve.

### Important: reservation must actually protect funds

If your LP vault is ERC-4626 and LPs can withdraw, reservation must reduce withdrawable funds. You have two implementation levels:

**Level 1 (Drop-in now):**

* Reservation only caps *how much you try to underwrite*.
* LP solvency still depends on vault not being drained.
* Still a big improvement because it prevents runaway underwriting.

**Level 2 (Real underwriting):**

* Modify `LiquidityVault4626` to enforce:

  * `withdrawableAssets = totalAssets - sumReservedAcrossMarkets`
* That requires vault to know reserved sum (global), or MarketRiskManager to be queried.

I recommend shipping Level 1 first, then Level 2.

---

## 3) Patch plan: `ChannelSettlement.finalizeCheckpoint`

You pasted:

```solidity
LEDGER.applyDeltas(marketId, sessionId, deltas);
```

### Replace with ERC-1155 apply

Add state:

* `IOutcomeToken1155 public outcomeToken;`
* `IMarketRiskManager public riskManager;` (optional at first)

Add setter(s) like your current style:

* `setOutcomeToken(address)`
* `setRiskManager(address)`

#### New internal: `_applyShareDeltasAs1155`

```solidity
function _applyShareDeltasAs1155(uint256 marketId, ShadowTypes.Delta[] calldata deltas) internal {
    for (uint256 i=0; i<deltas.length; i++) {
        int128 sd = deltas[i].sharesDelta;
        if (sd == 0) continue;

        if (sd > 0) {
            outcomeToken.mint(deltas[i].user, marketId, deltas[i].outcomeIndex, uint256(int256(sd)));
        } else {
            outcomeToken.burn(deltas[i].user, marketId, deltas[i].outcomeIndex, uint256(int256(-sd)));
        }
    }
}
```

### Add explicit LP solvency check (before transfer)

Right now it’s implicit via `safeTransfer` revert. Make it explicit:

```solidity
if (lpVault != address(0) && netTraderDelta > 0) {
    uint256 need = uint256(netTraderDelta);
    uint256 bal = IERC20(settlementAsset).balanceOf(lpVault);
    if (bal < need) revert Errors.LpVaultInsolvent(need, bal);
}
```

### Add risk reservation gate (the new feature)

Right before LP pays:

```solidity
if (address(riskManager) != address(0) && lpVault != address(0) && netTraderDelta > 0) {
    riskManager.reserveLpPayout(marketId, uint256(netTraderDelta));
}
```

If you don’t want reservation to increase unless the LP transfer succeeds, keep it where it is (right before pay). If transfer reverts, reservation reverts too (good).

### Full updated skeleton (diff style)

```solidity
// 1) replace ledger apply
_applyShareDeltasAs1155(marketId, deltas);

// 2) cash deltas + fees stays
(...) = _applyCashDeltasAndFees(...);

// 3) enforce LP vault required stays

// 4) if LP owes traders:
if (lpVault != address(0) && netTraderDelta > 0) {
    // solvency check
    ...
    // risk reserve
    if (address(riskManager) != address(0)) {
        riskManager.reserveLpPayout(marketId, uint256(netTraderDelta));
    }
    // pay
    ILiquidityVault4626(lpVault).payToTradingLedger(...);
}
```

---

## 4) Patch plan: `_applyCashDeltasAndFees` (add an accounting invariant)

Your fee math implies:

* `rawSum = sum(delta.cashDelta for delta !=0)`
* `netSum = sum(netDelta after fee)`
* `feesTotal = protocolFee + lpFee + creatorFee`
  Then:
* `rawSum == netSum + feesTotal`

Add tracking:

```solidity
int256 rawSum = 0;
uint256 feesTotal = 0;
...
rawSum += delta;
...
feesTotal += pf+lf+cf;
...
require(rawSum == netTraderDelta + int256(feesTotal), Errors.BadCashAccounting());
```

This gives you “exchange-grade” accounting sanity and makes audits far easier.

---

## 5) Patch plan: `MarketRegistry.redeem` (ERC-1155 source of truth)

Replace ledger read with token balance:

```solidity
uint256 tid = outcomeToken.id(marketId, winningOutcome);
uint256 shares = outcomeToken.balanceOf(msg.sender, tid);
if (shares == 0) revert NothingToRedeem();

hasRedeemed[marketId][msg.sender] = true;

// burn winning tokens
outcomeToken.burn(msg.sender, marketId, winningOutcome, shares);

// payout 1:1
payout = shares;
asset = getSettlementAsset(marketId);
vault.redeemPayout(msg.sender, asset, payout);
```

**Note:** because transfers are locked pre-resolution, you won’t get “weird” holders during trading. After resolution, transfers can happen, and whoever holds the token can redeem — that’s Polymarket-like behavior.

---

## 6) Where to set risk caps

### Option A (recommended): set cap at publish time in `MarketFactory.createFromDraft`

You already have:

* `draft.minSeed`
* you lock seed shares in `DraftClaimManager`
* you bind LP vault to market

Add:

* `riskManager.setMaxLpPayout(marketId, cap)`

Cap formulas (pick 1 to start):

* **Conservative:** `cap = seedAmount` (LP never pays out more than seed)
* **Growth:** `cap = seedAmount * K` (K from MarketPolicy)
* **TVL-linked:** `cap = min(seedAmount*K, tvl*X%)` (needs vault TVL read)

Keep it configurable via `MarketPolicy`.

---

## 7) Tests to add (matching your suite)

### A) ERC-1155 delta application

* finalize checkpoint mints tokens for positive sharesDelta
* finalize burns for negative sharesDelta
* burn fails if insufficient (should revert)

### B) Transfer lock

* try `safeTransferFrom` while market open → revert
* resolve market → transfer succeeds

### C) Redeem uses 1155

* mint winning tokens via checkpoint
* resolve
* redeem burns and pays exact amount

### D) Risk reservation cap

* set cap = 10
* create checkpoint with netTraderDelta = 11
* finalize → revert `RiskCapExceeded`

### E) Reservation increments only on LP owes

* netTraderDelta < 0 → no reserve
* netTraderDelta > 0 → reserve increases

### F) LP insolvency explicit revert

* LP vault balance < required
* finalize reverts `LpVaultInsolvent`

---

## 8) Why this is “better than Polymarket”

Polymarket’s safety comes from always-locked collateral sets (CTF).
You’ll have:

* ERC-1155 positions (same UX/composability at claim stage),
* but with **capital efficiency** (shared LP underwriting),
* and **on-chain risk controls** (cap + reservation),
* plus **checkpoint settlement** (micro-trade scalability).

That’s a real edge.

---

## What I can write next (if you want it as a repo-ready doc)

I can format the above into a single file:

* `docs/RetroPick-v3-ERC1155-RiskReservation.md`

including:

* exact storage fields to add in each contract,
* exact new errors/events,
* deployment wiring order (who sets what),
* and a “Phase 1/2” roadmap (reservation-only first, then vault-withdraw restriction).

Just say “make the doc file” and I’ll output it in clean markdown with all function signatures + expected revert reasons.
