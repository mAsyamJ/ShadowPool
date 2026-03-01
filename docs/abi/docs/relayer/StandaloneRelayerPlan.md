# Standalone Relayer Plan (Without Nitrolite)

**Last updated:** 2026-03-01  
**Context:** [RelayerArchitecture.md](RelayerArchitecture.md) | [RelayerOverview.md](RelayerOverview.md)

---

## 1. Current State

The relayer is **already mostly Nitrolite-independent**. Analysis of `apps/relayer` shows:

| Component | Nitrolite? | Purpose |
|-----------|------------|---------|
| `buildCheckpointPayload.ts` | No | Uses viem for EIP-712, ABI encode |
| `creRoutes.ts` | No | Operator signs via `privateKeyToAccount.signTypedData` |
| `routes.ts` (trading) | No | In-memory LS-LMSR; session store |
| `sessionStore.ts` | No | Pure TypeScript state |
| `nitroliteClient.ts` | Yes | Creates NitroliteClient — **never used for checkpoint signing** |
| `wsListener.ts` | Yes | Connects to Yellow WS; `parseAnyRPCResponse` — **callback never registered** |
| `index.ts` | Partial | Calls `connectYellowWS`, `getNitroliteClient` but no functional use |

**Conclusion:** Checkpoint building and trading are already Nitrolite-free. Only optional Yellow network glue exists and is effectively dead.

---

## 2. Standalone Mode Design

A **standalone relayer** runs without Nitrolite or Yellow WebSocket.

### 2.1 Remove

- `@erc7824/nitrolite` dependency
- `wsListener.ts` / Yellow WebSocket (or make strictly optional, off by default)
- `nitroliteClient.ts` instantiation

### 2.2 Optional: Finalizer Endpoint

Add `POST /cre/finalize/:sessionId` (or similar):

- Relayer fetches session state and deltas
- Submits `ChannelSettlement.finalizeCheckpoint(marketId, sessionId, deltas)` via RPC
- Requires `RPC_URL` and wallet (operator or dedicated finalizer key)

### 2.3 Minimal Environment (Standalone)

| Variable | Description |
|----------|-------------|
| `CHANNEL_SETTLEMENT_ADDRESS` | ChannelSettlement contract address |
| `OPERATOR_PRIVATE_KEY` | Operator key; signs checkpoints |
| `CHAIN_ID` | Chain ID for EIP-712 |
| `RPC_URL` | RPC endpoint (for finalizer if used) |

**Not needed in standalone mode:**

- `CUSTODY_ADDRESS`, `ADJUDICATOR_ADDRESS`
- `YELLOW_WS_URL`
- `CHALLENGE_DURATION` (contract uses 30 min fixed)

---

## 3. Implementation Steps

1. **Remove Nitrolite dependency**
   - Remove `@erc7824/nitrolite` from `package.json`
   - Remove or stub `nitroliteClient.ts`, `wsListener.ts`
   - Remove `connectYellowWS`, `getNitroliteClient` from `index.ts` (or gate behind env flag)

2. **Gate Yellow WS behind env**
   - If `YELLOW_WS_URL` is set, optionally connect (for future Yellow integration)
   - Default: do not connect

3. **Add finalizer (optional)**
   - `POST /cre/finalize/:sessionId` — relayer submits `finalizeCheckpoint` tx
   - Requires `RPC_URL`, optional `FINALIZER_PRIVATE_KEY` (or reuse operator)

---

## 4. Benefits

- Simpler deployment; no Nitrolite contracts or Yellow clearnet
- Fewer env vars; easier local/test setup
- Same security: EIP-712 signing, challenge window, reserve-on-submit
- CRE workflow unchanged: still fetches payload from relayer, sends `0x03` via Forwarder

---

## 5. See Also

- [RelayerArchitecture.md](RelayerArchitecture.md) — Architecture and lifecycle
- [RelayerConfiguration.md](RelayerConfiguration.md) — Standalone vs Nitrolite modes
