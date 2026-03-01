# CRE Workflow: Checkpoint Settlement

**Last updated:** 2026-03-01  
**Context:** [CREOverview.md](CREOverview.md) | [CREPipelineDiagram.md](CREPipelineDiagram.md)  
**Relayer:** [RelayerAPI.md](../relayer/RelayerAPI.md)

---

## 1. Overview

The checkpoint workflow fetches signed checkpoint payloads from the relayer and delivers them on-chain via the Chainlink Forwarder. The relayer builds payloads; the CRE workflow orchestrates fetch + delivery.

---

## 2. Trigger Options

| Trigger | Use case |
|---------|----------|
| **Cron** | Periodic checkpoint submission (e.g. every 5–10 min) |
| **HTTP** | On-demand when frontend or service requests a checkpoint run |

Typical: Cron trigger with schedule `0 */5 * * * *` (every 5 minutes).

---

## 3. Step-by-Step Flow

### 3.1 Discover Sessions

```
GET {relayerUrl}/cre/checkpoints
```

Returns list of sessions with checkpoint metadata. Alternatively:

```
GET {relayerUrl}/cre/sessions
```

Returns sessions ready for finalization (`resolveTime <= now`). Use when integrating with outcome resolution timing.

### 3.2 Get Checkpoint Spec

```
GET {relayerUrl}/cre/checkpoints/{sessionId}
```

**Response:** `digest`, `users`, `deltas`, `chainId`, `channelSettlementAddress`, `checkpoint`.

The `digest` is the EIP-712 hash users must sign. `users` is the list of addresses that must provide signatures.

### 3.3 Collect User Signatures

**Challenge:** The CRE workflow cannot prompt users directly. Signatures must come from:

1. **Frontend** — Users sign in wallet when prompted by app; frontend sends signatures to a signing service or workflow-triggered endpoint
2. **Signing service** — Separate service that holds or prompts for signatures; workflow fetches from it
3. **Pre-signed batch** — If users have pre-signed (e.g. at trade time), relayer or another service stores them; workflow fetches before POST

See [FrontendIntegration.md](../relayer/FrontendIntegration.md) for frontend signing flow.

### 3.4 Build Full Payload

```
POST {relayerUrl}/cre/checkpoints/{sessionId}
Body: { "userSigs": { "0xUserAddress": "0x...", ... } }
```

**Response:** `{ "payload": "0x03...", "format": "ChannelSettlement" }`

The payload is prefixed with `0x03` and is ready for `writeReport`.

### 3.5 Submit On-Chain

```
evmClient.writeReport(payload)
```

Workflow must target **CREReceiver**. The Forwarder delivers to CREReceiver; CREReceiver routes `report[0] == 0x03` to `submitSession` → SettlementRouter → ChannelSettlement.submitCheckpointFromPayload.

---

## 4. Post-Submit: Challenge Window and Finalize

### 4.1 Challenge Window (30 minutes)

After submit, users can **challenge** with a newer nonce. During this window, `finalizeCheckpoint` reverts.

### 4.2 Finalize (Permissionless)

After `block.timestamp >= challengeDeadline`, **anyone** can call:

```solidity
ChannelSettlement.finalizeCheckpoint(marketId, sessionId, deltas)
```

**Deltas source:** `GET /cre/checkpoints/:sessionId` returns `deltas`.

**Who typically finalizes:**

| Option | Description |
|--------|--------------|
| **Relayer finalizer** | Relayer exposes `POST /cre/finalize/:sessionId`; submits finalize tx via RPC |
| **CRE workflow** | Separate cron workflow that checks challenge deadline and submits finalize |
| **Bot** | Third-party bot watches for `challengeDeadline` and calls finalize |
| **Frontend** | User-triggered finalize from UI (requires RPC/wallet) |

Recommended: Relayer finalizer or dedicated CRE workflow, so finalize happens automatically after the window.

### 4.3 Cancel Escape Hatch

After `CANCEL_DELAY` (6 hours) from `createdAt`, anyone can call `cancelPendingCheckpoint(marketId, sessionId)` to release stuck reserves if no one finalized.

---

## 5. Relayer Endpoints Summary

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/cre/checkpoints` | List all checkpoint metadata |
| GET | `/cre/checkpoints/:sessionId` | Get digest, users, deltas for signature collection |
| POST | `/cre/checkpoints/:sessionId` | Build full payload; body `{ userSigs: { [address]: "0x..." } }`; returns `0x03`-prefixed payload |

See [RelayerAPI.md](../relayer/RelayerAPI.md) for full specs.

---

## 6. Configuration

| Variable | Description |
|----------|-------------|
| `relayerUrl` | Base URL of relayer (e.g. `http://localhost:8790`) |
| `CHAINLINK_FORWARDER` | Forwarder contract address |
| Receiver | Workflow must target **CREReceiver** (not CREPublishReceiver) |

---

## 7. Error Handling

| Relayer Response | Meaning |
|------------------|---------|
| 404 | Session not found |
| 400 | No deltas; or missing user signature on POST |
| 503 | `CHANNEL_SETTLEMENT_ADDRESS` or `OPERATOR_PRIVATE_KEY` not configured |

On-chain reverts (e.g. `BadDeltasHash`, `BadOperatorSig`, `NonceNotIncreasing`) indicate invalid payload; verify relayer state and signatures.

---

## 8. References

- [CREPipelineDiagram.md](CREPipelineDiagram.md) — Checkpoint sequence diagram
- [ContractRelayerInterface.md](../relayer/ContractRelayerInterface.md) — ChannelSettlement methods
- [CheckpointEIP712.md](../relayer/CheckpointEIP712.md) — EIP-712 spec
