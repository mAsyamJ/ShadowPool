# Remaining Implementation PR Plan

Last updated: 2026-02-16

This plan converts remaining partial/missing targets into ordered PRs with explicit scope and acceptance criteria.

## PR-1: Multi-Asset Completion

Goal:
- Complete per-market settlement asset support across all create flows.

Scope:
1. `src/core/MarketFactory.sol`
- Extend input payloads to include `settlementAsset`.
- Add asset allowlist validation (new config map in factory or policy).
- Route to `MarketRegistry.create*WithExpiryAndAsset(...)`.

2. `src/curation/CREPublishReceiver.sol`
- Extend publish params to include `settlementAsset`.
- Include it in EIP-712 params hash/signature.

3. `src/core/MarketRegistry.sol`
- Keep current settlement-asset storage logic.
- Add stronger validation if needed (non-zero when multi-asset mode is enforced).

4. Tests
- Add/extend tests for:
  - create market with custom settlement asset
  - checkpoint finalize uses that asset
  - redeem transfers correct asset

Acceptance:
- All market creation paths explicitly define settlement asset in multi-asset mode.

---

## PR-2: ResolutionManager Lifecycle

Goal:
- Move from direct confidence-only resolution to proposal/challenge/finalize lifecycle.

Scope:
1. Add `src/resolution/ResolutionManager.sol`.
- proposal struct with outcome/confidence/evidence/bond/timestamps/status
- challenge support with counter-evidence/counter-bond
- finalize after window

2. Integrate `MarketRegistry`.
- lock `resolve` to resolution manager (or keep router but route through manager)

3. Integrate oracle path.
- `OracleCoordinator` submits proposal payload to manager

4. Tests
- unauthorized propose/finalize
- challenge before/after window
- finalization correctness

Acceptance:
- Market outcome cannot be finalized without passing dispute lifecycle.

---

## PR-3: Checkpoint V2 Schema

Goal:
- Add richer transcript commitments with backward compatibility.

Scope:
1. `src/libs/ShadowTypes.sol`
- add `CheckpointV2`

2. `src/libs/ShadowEIP712.sol`
- add v2 typehash and digest/recovery functions

3. `src/execution/ChannelSettlement.sol`
- add submit/challenge/finalize functions for v2
- keep v1 path for migration period

4. Tests
- v1 continues to work
- v2 signature validation works
- wrong version/typehash fails

Acceptance:
- v2 checkpoints are verifiable and usable without breaking v1 flows.

---

## PR-4: Risk Hook Integration

Goal:
- Add configurable risk controls to checkpoint settlement.

Scope:
1. Add `src/risk/RiskManager.sol` (or `RiskSentinel.sol`).
- checkpoint policy checks
- optional global pause
- allow/deny responses for market/session

2. Integrate in `ChannelSettlement.finalizeCheckpoint`.
- pre-finalize risk check

3. Optional router-level pause in `SettlementRouter`.

4. Tests
- blocked checkpoint reverts
- allowed checkpoint succeeds
- pause/unpause behavior

Acceptance:
- settlement can be blocked by risk policy onchain.

---

## PR-5: CCIP Gateway Foundation

Goal:
- Establish hub-spoke message guardrails for future cross-chain sync.

Scope:
1. Add `src/crosschain/CCIPGateway.sol`.
- source chain allowlist
- sender allowlist
- nonce/replay protection
- typed message dispatch

2. Add message handlers for:
- market status sync
- resolution sync
- settlement root sync

3. Tests
- reject unknown source chain
- reject unknown sender
- reject replayed message

Acceptance:
- secure message ingress layer exists with replay protection.

---

## PR-6: Market Mirrors

Goal:
- Add spoke-side market state mirrors.

Scope:
1. Add mirror contract(s) under `src/crosschain/`.
2. Read-only market status and resolution replication.
3. Origin validation and replay protection.

Tests:
- valid updates applied
- invalid/replay updates rejected

Acceptance:
- spoke contracts expose synchronized market status from hub.

## Operational Notes

1. Keep `SessionFinalizer` as legacy fallback during migration.
2. Keep v1 checkpoint support until v2 has full operational rollout.
3. Do not remove pool modules until resolution + risk + multi-asset path is stable in production-like tests.

## Definition of Program Complete

The remaining program is complete when:
1. Multi-asset is fully enforced across all creation/settlement/redeem paths.
2. Resolution lifecycle with challenge window is live.
3. Checkpoint v2 is implemented and tested.
4. Risk hooks can block unsafe settlements.
5. CCIP ingress and mirror sync foundation is deployed and tested.
