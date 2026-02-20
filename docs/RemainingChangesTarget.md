# Remaining Changes Target (Post-Current-State)

Last updated: 2026-02-16  
Depends on: `.docs/ChangesTarget.md`, `.docs/CurrentSmartContract.md`

## Purpose

This document isolates only the work that is not fully complete in current contracts.

Status legend:
- `Partial`
- `Missing`

## A) Partial Items

## A1. Multi-asset vault + per-market settlement asset
Status: `Partial`

What exists now:
- `src/execution/MultiAssetVault.sol`
- `src/core/MarketRegistry.sol` has:
  - `settlementAssetByMarketId`
  - `defaultSettlementAsset`
  - `getSettlementAsset(marketId)`
- `src/execution/ChannelSettlement.sol` uses `marketRegistry.getSettlementAsset(marketId)` when `multiAssetVault` is configured.

Remaining gaps:
1. No consistent asset selection in all market creation paths.
- Most factory creation routes do not explicitly set `settlementAssetByMarketId`.

2. Curated publish params do not include settlement asset.
- `CREPublishReceiver` and `MarketFactory.DraftPublishParams` currently do not carry asset.

3. No conversion/oracle policy for cross-asset collateral.
- Current implementation assumes direct settlement in selected asset.

Definition of done:
1. Add explicit settlement asset in all creation paths:
- Factory v1/v2 feed path
- Curated `createFromDraft` path
2. Add validation that chosen asset is allowlisted.
3. Add tests for per-market asset settlement in:
- checkpoint finalize
- market redeem

---

## B) Missing Items

## B1. ResolutionManager (bond/evidence/dispute)
Status: `Missing`

Target:
- Introduce `src/resolution/ResolutionManager.sol`.
- Move authoritative finalize-to-registry flow behind dispute lifecycle.

Minimum design:
- `proposeResolution(marketId, outcome, confidence, evidenceHash, bondAmount)`
- `challengeResolution(marketId, counterEvidenceHash, bondAmount)`
- `finalizeResolution(marketId)` after dispute window

Required integration:
- `MarketRegistry.resolve` caller should become `ResolutionManager` (or router -> manager -> registry).
- `OracleCoordinator` can submit proposals, not direct final resolution.

Definition of done:
1. Resolution proposals stored onchain.
2. Dispute window enforced.
3. Final outcome only set through finalized proposal.
4. Full tests for propose/challenge/finalize and unauthorized access.

---

## B2. Checkpoint v2 fields and typed transcript commitments
Status: `Missing`

Target fields (v2):
- `epoch`
- `accountsRoot`
- `txRoot`
- `prevStateHash`
- `policyHash`

Current:
- `ShadowTypes.Checkpoint` still uses v1 schema.

Definition of done:
1. Add versioned checkpoint schema (`CheckpointV2`) in `src/libs/ShadowTypes.sol`.
2. Add new EIP-712 typehash and digest path in `src/libs/ShadowEIP712.sol`.
3. Backward compatibility path for v1 during migration.
4. Tests for both versions and signature validity.

---

## B3. RiskManager / Sentinel hooks
Status: `Missing`

Target:
- Introduce a risk control contract that can enforce guardrails during settlement.

Minimum capabilities:
- pause settlement route
- reject checkpoint by policy hash or risk rule
- optional forced-checkpoint trigger

Integration candidates:
- `ChannelSettlement` (pre-finalize checks)
- `SettlementRouter` (optional global pause)

Definition of done:
1. Risk hook contract exists and is owner/governance controlled.
2. Channel settlement enforces risk hook decisions.
3. Tests for blocked and allowed settlements.

---

## B4. Cross-chain CCIP hub-spoke custody
Status: `Missing`

Target:
- `src/crosschain/CCIPGateway.sol` for controlled message ingress/egress.

MVP topology:
1. Hub chain:
- canonical custody vault
- canonical settlement
2. Spoke chains:
- market mirrors and state replication

Definition of done:
1. Gateway validates source chains and sender allowlist.
2. Message types for:
- market state sync
- resolution sync
- settlement root sync
3. Tests for unauthorized source/sender rejection and valid message processing.

---

## B5. Market mirror contracts
Status: `Missing`

Target:
- Lightweight read/announce contracts on spoke chains.

Definition of done:
1. Mirror tracks canonical market status and resolution.
2. Immutable origin mapping and replay protection.
3. Tests for sync correctness and replay rejection.

## C) Priority Order

1. Finish multi-asset completeness (A1)
2. Build ResolutionManager (B1)
3. Add checkpoint v2 transcript commitments (B2)
4. Add RiskManager hooks (B3)
5. Add CCIP + mirrors (B4, B5)

## D) Test Additions Required

1. Multi-asset end-to-end settlement and redeem by market asset
2. Resolution propose/challenge/finalize lifecycle
3. Checkpoint v1 and v2 coexistence
4. Risk hook blocking behavior
5. Cross-chain gateway auth/replay controls
