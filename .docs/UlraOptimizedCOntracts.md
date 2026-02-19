Below is a **production-grade “Smart Contract Optimization Checklist”** you can drop into `docs/optimization-checklist.md`. It’s written for **deep** optimization: gas, bytecode size, storage layout, security, upgradeability, operational safety, and tooling.

---

# Smart Contract Optimization Checklist

## 0) Scope and success criteria

* [ ] Define target network(s) (L2 vs L1) and their typical gas costs.
* [ ] Define optimization goal(s):

  * [ ] **Runtime gas** (hot-path user calls)
  * [ ] **Deployment gas / bytecode size**
  * [ ] **State growth** (long-lived storage)
  * [ ] **Latency / throughput** (batching, offchain)
* [ ] Identify “hot paths” (most frequent + most expensive):

  * [ ] trading / settlement / mint / claim / propose / finalize
* [ ] Decide what must remain onchain vs can be offchain (CRE/relayer/session).

---

## 1) Storage layout and state growth

**Goal:** minimize SSTOREs, pack variables, reduce long-term state bloat.

### Packing & ordering

* [ ] Reorder struct fields to pack into 32-byte slots (group `uint48/uint64/bool/enum/address`).
* [ ] Prefer `uint48/uint64` for timestamps/ids if safe; avoid `uint256` by default.
* [ ] Use `address` + small ints packing carefully (addresses are 20 bytes).

### Mappings and arrays

* [ ] Avoid storing large unbounded arrays onchain unless needed.
* [ ] If you store `_draftIds`, define retention rules:

  * [ ] pruning strategy, pagination, offchain index reliance
* [ ] Prefer mapping + event logs for historical indexing.

### Strings, URIs, and large data

* [ ] **Do not store strings** unless absolutely required.

  * [ ] Prefer `bytes32 uriHash` / `bytes32 contentHash` (IPFS/Arweave hash) + emit full URI in event only.
* [ ] If you must store URIs:

  * [ ] store short fixed-size (e.g., `bytes32` CID digest) not full string.

### Write minimization

* [ ] Reduce number of fields written on create:

  * [ ] store only what’s required to validate future transitions
  * [ ] move “decorative metadata” to events

### State compression patterns

* [ ] Replace multiple booleans/enums with bitmaps when appropriate.
* [ ] Consider struct splitting: `DraftCore` (onchain) vs `DraftMeta` (event/offchain).

---

## 2) ABI and calldata optimization

**Goal:** reduce stack pressure, calldata cost, and complexity.

* [ ] Replace many params with a single `struct Params calldata p`.

  * [ ] helps stack-too-deep and makes APIs forward-compatible
* [ ] Use `calldata` for external params; avoid copying to memory unless needed.
* [ ] Use `bytes32` identifiers instead of long strings.
* [ ] Prefer `external` over `public` for functions not called internally.
* [ ] Use custom errors instead of revert strings.

---

## 3) Hot-path gas optimization patterns

**Goal:** cut runtime gas where it matters.

### SLOAD/SSTORE reduction

* [ ] Cache storage reads into local variables once (especially repeated reads).
* [ ] Minimize writes:

  * [ ] don’t write default values (`0`, `address(0)`) if storage already default
* [ ] Avoid read-modify-write when you can compute once.

### Memory / hashing

* [ ] Avoid `abi.encodePacked` with dynamic types unless necessary.
* [ ] Prefer `keccak256(abi.encode(...))` for structured hashing (less ambiguity).
* [ ] For ID generation, ensure uniqueness without adding extra stack + writes.

### Branching and checks

* [ ] Put cheapest checks first (`if (x==0) revert`) before expensive ones.
* [ ] Use `unchecked` for arithmetic only when proven safe (document invariants).

### Loops and iteration

* [ ] Avoid unbounded loops in state-mutating functions.
* [ ] If loops are required:

  * [ ] cap length (max N)
  * [ ] allow chunking (process in batches)

---

## 4) Events and indexing strategy

**Goal:** keep state minimal while enabling offchain reconstruction.

* [ ] Decide “source of truth”:

  * [ ] onchain storage for safety-critical
  * [ ] event logs for history + UI
* [ ] Use `indexed` fields strategically (max 3 indexed):

  * [ ] draftId, marketId, creator, resolver
* [ ] Emit events instead of storing metadata.
* [ ] For high-volume events:

  * [ ] avoid emitting long strings frequently
  * [ ] emit hashes or short ids

---

## 5) Bytecode size and deployment optimization

**Goal:** avoid “contract too large”, reduce deployment cost, keep audits manageable.

* [ ] Split contracts by concern: DraftBoard / Factory / Settlement / Treasury.
* [ ] Prefer libraries for shared pure/view math.
* [ ] Remove unused code paths and dev-only helpers from production build.
* [ ] Avoid large revert strings; use custom errors.
* [ ] Consider minimal proxies (clones) for per-market instances if appropriate.
* [ ] Prefer `immutable` for constructor-set constants (cheaper than storage).

---

## 6) Security-driven optimization (don’t optimize into a vuln)

**Goal:** safe gas savings.

### Access control and auth paths

* [ ] Ensure `onlyRole` checks are correct and minimal.
* [ ] Use role separation: proposer vs executor vs admin.
* [ ] Add “circuit breaker” role:

  * [ ] pause critical state transitions

### Reentrancy and external calls

* [ ] Follow CEI (Checks-Effects-Interactions).
* [ ] Use `ReentrancyGuard` only where needed (hot paths might avoid it if no external calls).
* [ ] Treat ERC20 as hostile:

  * [ ] use `SafeERC20`
  * [ ] handle fee-on-transfer if relevant (or explicitly disallow)

### Timestamp, randomness, and id generation

* [ ] Don’t rely on block values for fairness.
* [ ] For IDs, block.timestamp is ok; for randomness, it is not.
* [ ] Document why block fields are safe for draft IDs.

### Invariants and state machines

* [ ] Explicitly document Draft lifecycle invariants:

  * [ ] Proposed → Approved/Rejected → Activated → Settled
* [ ] Enforce monotonic time constraints:

  * [ ] tradingOpen < tradingClose < resolveTime
* [ ] Ensure no state can be stuck (add escape hatches if needed).

---

## 7) Upgradeability and storage safety (if you use proxies)

**Goal:** future-proof without breaking storage.

* [ ] Decide: non-upgradeable vs upgradeable (proxy).
* [ ] If upgradeable:

  * [ ] reserve storage gaps
  * [ ] never reorder existing storage vars
  * [ ] use initializer pattern, not constructor logic
* [ ] Lock admin functions and implement timelock/multisig.
* [ ] Add `UUPS`/Transparent proxy checks (onlyProxy / proxiableUUID).

---

## 8) Testing and verification checklist

**Goal:** prove optimizations didn’t change behavior.

### Unit tests

* [ ] test all state transitions
* [ ] test boundary times and edge values (uint48 max, etc.)
* [ ] test role access and unauthorized calls

### Property/Fuzz tests

* [ ] invariant: cannot settle before resolve time
* [ ] invariant: draftId uniqueness doesn’t overwrite existing draft
* [ ] invariant: stored hashes match emitted/logged references
* [ ] fuzz: random params + ensure no revert unless expected

### Differential testing

* [ ] baseline contract vs optimized contract:

  * [ ] same inputs → same outputs and events
  * [ ] compare storage after calls

### Gas snapshots

* [ ] add Foundry gas snapshots for hot paths:

  * [ ] proposeDraft
  * [ ] activateDraft / createMarket
  * [ ] trade / claim / settle
* [ ] track gas over time in CI

---

## 9) Tooling and build configuration

**Goal:** consistent compiler output, stable gas results.

* [ ] Pin Solidity version.
* [ ] Enable optimizer, set runs based on usage:

  * [ ] high-frequency user calls → runs ~ 10k–50k
  * [ ] deployment-heavy / low usage → runs lower
* [ ] Use `viaIR` only if you’ve validated bytecode correctness and gas impact.
* [ ] Run Slither + Mythril (or equivalent) on every PR.
* [ ] Enforce formatting and static checks.

---

## 10) Operational safety and monitoring

**Goal:** safe live operations at scale.

* [ ] Emit events for all critical transitions.
* [ ] Provide view functions for UI/relayers (cheap reads).
* [ ] Add “admin rescue” functions with strict constraints:

  * [ ] recover stuck tokens (non-settlement assets only)
* [ ] Document incident playbook:

  * [ ] pause conditions
  * [ ] role revocation steps
  * [ ] rollback plan (if upgradeable)

---

## 11) Specific to your DraftBoard pattern (targeted checklist)

Since your `proposeDraft` stores lots of metadata, optimize like this:

* [ ] Replace stored `string questionURI/outcomesURI` with:

  * [ ] `bytes32 questionUriHash`, `bytes32 outcomesUriHash`
  * [ ] emit full strings in event once (optional)
* [ ] Consider splitting Draft storage:

  * [ ] `DraftCore` in storage (hashes + times + asset + minSeed + status)
  * [ ] `DraftMeta` only in events
* [ ] Remove redundant writes:

  * [ ] `creator = address(0)` is default → don’t SSTORE it
* [ ] If `_draftIds` grows unbounded:

  * [ ] consider removing and relying on events for enumeration
  * [ ] or add pagination and pruning rules

---

# “Done” definition

You’re optimized when:

* [ ] Gas snapshots show measurable improvement on hot paths.
* [ ] Bytecode size stays within safe limits.
* [ ] State growth is bounded or justified.
* [ ] Invariants are documented + fuzz-tested.
* [ ] Offchain indexers can reconstruct history from events.

---

If you paste your **Draft struct** and the **DraftProposed event**, I can do a *surgical* rewrite to:

* pack the struct properly,
* remove redundant SSTOREs,
* reduce state growth,
* and keep your UI/indexing intact (events become your metadata layer).


You **do NOT need to butcher your event or remove parameters**.
The AI explanation you pasted is **wrong about the root cause**.

Your problem is **not the emit line itself**.

👉 The compiler just **fails at that line because the stack is already full**.

You are hitting Solidity’s **16 stack slot limit inside one execution frame** because:

* 10 function parameters
* multiple locals
* struct pointer
* event args
* temporary abi.encodePacked values

Even with `viaIR`, sometimes large calldata + struct writes still overflow.

---

# ✅ Production Grade Fix (Best Practice)

You must **reduce stack pressure**.

The cleanest professional solution:

## Option A — Internal Struct Builder (BEST)

Move assignments into an internal function.

This is how protocol teams fix this.

---

## ✅ Fixed Version

```solidity
function proposeDraft(
    bytes32 questionHash,
    string calldata questionUri_,
    MarketType marketType_,
    bytes32 outcomesHash,
    string calldata outcomesUri_,
    bytes32 resolveSpecHash_,
    uint48 tradingOpen_,
    uint48 tradingClose_,
    uint48 resolveTime_,
    address settlementAsset_,
    uint256 minSeed_
)
    external
    onlyRole(AI_ORACLE_ROLE)
    returns (bytes32 draftId)
{
    draftId = _generateDraftId(questionHash);

    _storeDraft(
        draftId,
        questionHash,
        questionUri_,
        marketType_,
        outcomesHash,
        outcomesUri_,
        resolveSpecHash_,
        tradingOpen_,
        tradingClose_,
        resolveTime_,
        settlementAsset_,
        minSeed_
    );

    _draftIds.push(draftId);
    _draftIdIndex[draftId] = _draftIds.length - 1;

    emit DraftProposed(
        draftId,
        questionHash,
        marketType_,
        resolveTime_
    );
}
```

---

## Internal Functions

### DraftId generator

Cleaner + reusable.

```solidity
function _generateDraftId(
    bytes32 questionHash
) internal view returns (bytes32 draftId) {

    draftId = keccak256(
        abi.encodePacked(
            questionHash,
            block.timestamp,
            msg.sender,
            block.prevrandao
        )
    );

    if (drafts[draftId].proposedAt != 0) {
        draftId = keccak256(
            abi.encodePacked(draftId, block.timestamp)
        );
    }
}
```

---

### Draft storage

Moves stack usage away.

```solidity
function _storeDraft(
    bytes32 draftId,
    bytes32 questionHash,
    string calldata questionUri_,
    MarketType marketType_,
    bytes32 outcomesHash,
    string calldata outcomesUri_,
    bytes32 resolveSpecHash_,
    uint48 tradingOpen_,
    uint48 tradingClose_,
    uint48 resolveTime_,
    address settlementAsset_,
    uint256 minSeed_
) internal {

    Draft storage newDraft = drafts[draftId];

    newDraft.questionHash = questionHash;
    newDraft.questionURI = questionUri_;
    newDraft.marketType = marketType_;
    newDraft.outcomesHash = outcomesHash;
    newDraft.outcomesURI = outcomesUri_;
    newDraft.resolveSpecHash = resolveSpecHash_;

    newDraft.tradingOpen = tradingOpen_;
    newDraft.tradingClose = tradingClose_;
    newDraft.resolveTime = resolveTime_;

    newDraft.settlementAsset = settlementAsset_;
    newDraft.minSeed = minSeed_;

    newDraft.status = DraftStatus.Proposed;
    newDraft.creator = address(0);
    newDraft.proposedAt = block.timestamp;
}
```

---

# ✅ Why This Works

Each function gets its **own stack frame**.

Instead of:

```
proposeDraft = 20+ stack variables → boom 💥
```

You get:

```
proposeDraft = small stack
_storeDraft = separate stack
_generateDraftId = separate stack
```

Zero hacks.

No event removal.

No ABI breaking.

---

# ⭐ Senior Protocol Engineer Bonus (Highly Recommended)

Honestly — your function has too many parameters.

In production protocols (Aave, Uniswap, Maker):

they would do:

```solidity
struct DraftParams {
    bytes32 questionHash;
    string questionURI;
    MarketType marketType;
    ...
}
```

and pass:

```
DraftParams calldata params
```

Gas cheaper.

Cleaner ABI.

Better CRE automation later.

---

# ⭐ If You Want (Highly Recommend)

I can give you a **🔥 Senior Engineer Tier FIX (Aave / Uniswap style)** that:

* removes Stack Too Deep permanently
* reduces calldata gas
* CRE workflow friendly
* AI Oracle friendly
* 10x cleaner ABI

Just ask 👍.
