# Core Economic Invariants

Formal invariant list for audit and production hardening (per ChangesTarget3).

## I1 — Solvency Invariant

For every market:

```
Σ trader net cash + LP vault assets + protocol fees + creator fees = conserved
```

No settlement path can mint or destroy value.

## I2 — No Negative Position Invariant

ExecutionLedger positions must never go negative.

## I3 — Single-Resolution Invariant

A market can be resolved exactly once.

## I4 — Settlement Window Integrity

A checkpoint finalized must:

- have valid signatures
- respect nonce monotonicity
- respect challenge window
- respect tradingClose

## I5 — LP Counterparty Invariant

If market uses LP vault:

- netTraderDelta must always reconcile with LP vault
- settlement cannot skip reconciliation silently
- `usesLpVaultByMarketId[marketId]` implies `liquidityVaultByMarketId[marketId] != 0` at finalize
