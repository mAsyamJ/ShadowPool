# Relayer Configuration

**Last updated:** 2026-03-01  
**Context:** [RelayerOverview.md](RelayerOverview.md) | [StandaloneRelayerPlan.md](StandaloneRelayerPlan.md)

---

## 1. Overview

The relayer supports two modes:

| Mode | Required env | Purpose |
|------|--------------|---------|
| **Standalone (ChannelSettlement path)** | `CHANNEL_SETTLEMENT_ADDRESS`, `OPERATOR_PRIVATE_KEY` | Build and sign checkpoints for ChannelSettlement; no Nitrolite |
| **Nitrolite / Yellow (optional)** | `OPERATOR_PRIVATE_KEY`, optionally `CUSTODY_ADDRESS`, `ADJUDICATOR_ADDRESS`, `YELLOW_WS_URL` | Full Nitrolite channel setup; optional for basic relayer |

---

## 2. Environment Variables

### 2.1 Required for Standalone (Checkpoint Path)

| Variable | Description |
|----------|-------------|
| `CHANNEL_SETTLEMENT_ADDRESS` | ChannelSettlement contract address. Required for `GET/POST /cre/checkpoints/:sessionId`. If unset, endpoints return 503. |
| `OPERATOR_PRIVATE_KEY` | Private key for operator; signs checkpoints. Must match `ChannelSettlement.operator`. Required for `POST /cre/checkpoints/:sessionId`. |

### 2.2 Chain / RPC (Standalone + Finalizer)

| Variable | Description | Default |
|----------|-------------|---------|
| `CHAIN_ID` | Chain ID for EIP-712 checkpoint signing | `11155111` (Sepolia) |
| `RPC_URL` | RPC endpoint (for finalizer if used) | — |

### 2.3 Nitrolite / Yellow (Optional)

| Variable | Description | Default |
|----------|-------------|---------|
| `CUSTODY_ADDRESS` | Nitrolite custody contract | — |
| `ADJUDICATOR_ADDRESS` | Nitrolite adjudicator contract | — |
| `YELLOW_WS_URL` | Yellow WebSocket (e.g. clearnet sandbox) | — |
| `CHALLENGE_DURATION` | Challenge window (Nitrolite) | `3600` |

### 2.4 Server

| Variable | Description | Default |
|----------|-------------|---------|
| `RELAYER_PORT` | HTTP server port | `8790` |

---

## 3. Standalone Mode

With only `CHANNEL_SETTLEMENT_ADDRESS` and `OPERATOR_PRIVATE_KEY`:

- Checkpoint API works: `GET/POST /cre/checkpoints/:sessionId`
- Operator signs via viem `signTypedData`
- No NitroliteClient, no Yellow WebSocket

See [StandaloneRelayerPlan.md](StandaloneRelayerPlan.md) for full standalone design.

---

## 4. Nitrolite Mode (Optional)

When Nitrolite contracts and Yellow are configured:

- `NitroliteClient` may be created (custody, adjudicator, channel lifecycle)
- Yellow WebSocket may connect for clearnet updates
- **Checkpoint signing still uses viem**; Nitrolite is not used for checkpoint EIP-712

---

## 5. Deployment Consistency

For any network (e.g. Avalanche Fuji):

1. Deploy via `script/DeployTestnet.s.sol` with `OPERATOR` = address derived from `OPERATOR_PRIVATE_KEY`.
2. Set `CHANNEL_SETTLEMENT_ADDRESS` in relayer `.env` to the deployed ChannelSettlement address.
3. Set `CHAIN_ID` to the deployment chain (e.g. `43113` for Fuji).

---

## 6. References

- [StandaloneRelayerPlan.md](StandaloneRelayerPlan.md) — Nitrolite removal, minimal env
- [RelayerArchitecture.md](RelayerArchitecture.md) — Architecture and lifecycle
