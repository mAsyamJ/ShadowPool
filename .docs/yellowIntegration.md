### What `SessionFinalizer` / “Yellow” does and does *not* do

Looking at `SessionFinalizer`:

```52:89:src/core/SessionFinalizer.sol
    function finalizeSession(bytes calldata payload) external override {
        SessionPayload memory decoded = abi.decode(payload, (SessionPayload));
        ...
        bytes32 sessionKey = keccak256(abi.encode(decoded.marketId, decoded.sessionId));
        ...
        bytes32 stateHash = keccak256(
            abi.encode(decoded.marketId, decoded.sessionId, decoded.participants, decoded.balances)
        ).toEthSignedMessageHash();
        if (stateHash.recover(decoded.backendSignature) != trustedBackend) revert InvalidSignature();

        for (uint256 i = 0; i < decoded.participants.length; i++) {
            bytes32 userHash = keccak256(
                abi.encode(decoded.marketId, decoded.sessionId, decoded.participants[i], decoded.balances[i])
            ).toEthSignedMessageHash();
            if (userHash.recover(decoded.signatures[i]) != decoded.participants[i]) revert InvalidSignature();
        }

        finalizedSessions[sessionKey] = true;

        for (uint256 i = 0; i < decoded.participants.length; i++) {
            if (!TOKEN.transfer(decoded.participants[i], decoded.balances[i])) revert Errors.InvalidAmount();
        }

        emit SessionFinalized(decoded.marketId, decoded.sessionId, decoded.participants, decoded.balances);
    }
```

From the architecture doc:

```203:231:src/core/SessionFinalizer.sol
#### SessionFinalizer
**Role**: Implements the Yellow session finalization flow by validating an off-chain snapshot signed by both a trusted backend and individual users, then paying out ERC-20 balances.
...
- Keeps on-chain verification narrow (signatures and balance transfers), making it easier to reason about security.
```

So:

- **On-chain (`SessionFinalizer`)**:
  - Holds **token balance** for sessions.
  - Stores a **“finalizedSessions”** flag per `(marketId, sessionId)`.
  - Verifies **one backend signature over the global snapshot** and **one per-user signature** over their own balance.
  - Performs **simple balance transfers**.

- **Off-chain (Yellow SDK / backend)**:
  - Runs the **actual session logic**: joining, trading, PnL, risk, fee logic, etc.
  - Aggregates state into `SessionPayload` and gets all signatures.
  - Sends that payload on-chain through the CRE → Coordinator → Router → Finalizer pipeline.

So your understanding is correct: **the Yellow/SessionFinalizer part on-chain only holds funds + final snapshot verification; all “smart” session logic is intentionally off-chain.**

---

### Is that a good design?

**Yes, for this use case it’s a pretty standard and sensible design.** Main points:

- **Separation of concerns**  
  - On-chain: very small, auditable surface (ECDSA checks + transfers + one-shot guard).
  - Off-chain: flexible, upgradable session logic (you can change trading rules without redeploying contracts).

- **Gas & UX**  
  - Users can do many actions in a session off-chain and pay gas **once** at finalization.
  - You avoid heavy on-chain state updates for each trade.

- **Security model**  
  - Extra trust assumption: a **trusted backend** must honestly aggregate and not censor.
  - That power is bounded by:
    - The backend must sign a snapshot consistent with all user-signed per‑user balances.
    - Users can refuse to sign if they disagree with their balance.
  - This is exactly what the docs state:

    ```502:508:.docs/architecture.md
    - Yellow sessions:
      - Offer a smoother UX ...
      - Rely on an additional trust assumption: the `trustedBackend` must honestly aggregate trades and not censor users.
      - Mitigate unilateral backend power via per-user signatures, ensuring each participant consents to their final balance.
    ```

This is a **hybrid CEX/DEX-style model**: centralized matching/risk engine, cryptographically enforced final balances on-chain.

---

### “Will the system work as smart contract only finalizing sessions?”

Depends what you mean:

- **1) On-chain is only used at the end to finalize sessions (everything else off-chain):**  
  - **Yes, that is exactly how the Yellow session flow is designed.**  
  - The CRE → `CREReceiver` → `OracleCoordinator` → `SettlementRouter` → `SessionFinalizer` path already assumes:
    - All session actions happened off-chain.
    - The only on-chain step is `finalizeSession(payload)` which moves tokens.

- **2) No off-chain logic at all, pure smart contracts (no backend/SDK):**  
  - **Then Yellow sessions, as designed here, cannot exist**, because:
    - Someone has to compute the final balances and produce `backendSignature` + per-user signatures.
    - That “someone” is currently modeled as an off-chain backend + Yellow SDK; the contracts do not implement order matching or session PnL logic.
  - However, **the rest of the system (classic prediction markets) *does* already work fully on-chain** via `PredictionMarket` with CRE settlement. Yellow is an optional extra flow, not a dependency.

So in short:

- **Yes:** `SessionFinalizer` is intentionally “dumb”: just custody + signature checks + payouts.  
- **Yes:** It’s a reasonable and common design for off-chain sessions / off-chain order books.  
- **No:** You cannot get rid of off-chain logic entirely if you want Yellow sessions; you would instead use the existing `PredictionMarket` path for fully on-chain behavior.



---

## 1. Does ShadowPool connect to Yellow when you develop it?

ShadowPool gives you the on-chain side and the interface; the Yellow off-chain part you build connects to it via the CRE pipeline.

What ShadowPool provides (ready to use):

| Component | Purpose |
|-----------|---------|
| `SessionFinalizer` | Contract that verifies signatures and pays out from `SessionPayload` |
| `SessionPayload` format | Exact struct: `marketId`, `sessionId`, `participants[]`, `balances[]`, `signatures[]`, `backendSignature` |
| CRE path | `report[0] == 0x03` → `CREReceiver` → `OracleCoordinator.submitSession()` → `SettlementRouter.finalizeSession()` → `SessionFinalizer.finalizeSession()` |

How your Yellow backend connects:

1. Implement session logic (join, trade, PnL, fees, etc.).
2. Build a `SessionPayload` in that format.
3. Send it to the CRE/Keystone workflow that calls `CREReceiver.onReport()` with:

```solidity
bytes.concat(bytes1(0x03), abi.encode(payload))
```

The test shows the exact flow (`YellowSessionFlow.t.sol`):

```80:82:test/YellowSessionFlow.t.sol
        bytes memory report = bytes.concat(bytes1(0x03), abi.encode(payload));
        vm.prank(forwarder);
        receiver.onReport("", report);
```

So the “connection” is:

1. The `SessionPayload` and signing rules defined in `SessionFinalizer`.
2. The CRE pipeline (`0x03` → `CREReceiver` → coordinator → router → finalizer).

There is no Yellow SDK in the repo. You build the off-chain backend that produces the correct payload and submits it through CRE (Chainlink Keystone Forwarder). As long as your payload matches the contract interface and is sent via that pipeline, it will work.

---

## 2. Will it reduce gas for trading?

Yes. That’s exactly what this design is for.

| Flow | Trades | On-chain transactions |
|------|--------|------------------------|
| Classic on-chain | N trades in `PredictionMarket` | N `predict()` calls (one per user per market) |
| Yellow session | N trades off-chain in session | 1 `finalizeSession()` to settle all participants |

Off-chain:

- Users join the session.
- All trades are matched/computed off-chain.
- Each user signs their final balance.
- Backend signs the full snapshot.

On-chain:

- One `finalizeSession(payload)` call.
- Verifies backend + per-user signatures.
- Pays everyone in a single transaction.

So gas is paid once for the whole session instead of once per trade. The more activity in a session, the greater the gas savings.