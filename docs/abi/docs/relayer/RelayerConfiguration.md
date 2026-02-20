# Relayer Configuration

**Last updated:** 2026-02-20  
**Source:** [.env.example](../../../../../../apps/relayer/.env.example) | [nitroliteClient.ts](../../../../../../apps/relayer/src/yellow/nitroliteClient.ts)  
**Context:** [RelayerOverview.md](RelayerOverview.md)

---

## 1. Overview

The relayer uses `@erc7824/nitrolite` v0.5.x for NitroliteClient. Configuration is via environment variables. Two modes:

| Mode | Required env | Purpose |
|------|--------------|---------|
| **Nitrolite Yellow (checkpoint path)** | `CHANNEL_SETTLEMENT_ADDRESS`, `OPERATOR_PRIVATE_KEY` | Build and sign checkpoints for ChannelSettlement |
| **NitroliteClient (Yellow Network)** | `OPERATOR_PRIVATE_KEY`, optionally `CUSTODY_ADDRESS`, `ADJUDICATOR_ADDRESS` | Full Nitrolite channel setup; optional for basic relayer |

---

## 2. Environment Variables

### 2.1 Required for Nitrolite Yellow (ChannelSettlement Path)

| Variable | Description |
|----------|-------------|
| `CHANNEL_SETTLEMENT_ADDRESS` | ChannelSettlement contract address. Required for `GET/POST /cre/checkpoints/:sessionId`. If unset, endpoints return 503. |
| `OPERATOR_PRIVATE_KEY` | Private key for operator; signs checkpoints. Must match `ChannelSettlement.operator`. Required for `POST /cre/checkpoints/:sessionId`. |

### 2.2 Nitrolite / Yellow Network (Optional)

| Variable | Description | Default |
|----------|-------------|---------|
| `CUSTODY_ADDRESS` | Nitrolite custody contract | `0x...01` |
| `ADJUDICATOR_ADDRESS` | Nitrolite adjudicator contract | `0x...02` |
| `CHAIN_ID` | Chain ID for EIP-712 checkpoint signing | `11155111` (Sepolia) |
| `RPC_URL` | RPC endpoint | — |
| `ALCHEMY_RPC_URL` | Alternate RPC | — |
| `CHALLENGE_DURATION` | Challenge window seconds (Nitrolite) | `3600` |

### 2.3 Server

| Variable | Description | Default |
|----------|-------------|---------|
| `RELAYER_PORT` | HTTP server port | `8790` |
| `YELLOW_WS_URL` | Yellow WebSocket (e.g. clearnet sandbox) | `wss://clearnet-sandbox.yellow.com/ws` |

---

## 3. NitroliteClient Setup

When `OPERATOR_PRIVATE_KEY` is set, the relayer creates a NitroliteClient ([nitroliteClient.ts](../../../../../../apps/relayer/src/yellow/nitroliteClient.ts)):

| Config | Source | Role |
|--------|--------|------|
| **WalletStateSigner** | `privateKeyToAccount(OPERATOR_PRIVATE_KEY)` | Signs channel state updates |
| **publicClient** | viem `createPublicClient` (RPC) | Chain reads |
| **walletClient** | viem `createWalletClient` with operator account | Transaction signing |
| **addresses** | `CUSTODY_ADDRESS`, `ADJUDICATOR_ADDRESS` | Nitrolite contract addresses |
| **challengeDuration** | `CHALLENGE_DURATION` (default 3600) | Challenge window in seconds |

The NitroliteClient manages custody, adjudicator, and channel lifecycle per ERC-7824. If `OPERATOR_PRIVATE_KEY` is not set, NitroliteClient is disabled; the checkpoint API still works if `CHANNEL_SETTLEMENT_ADDRESS` is set (operator signs via the same key when provided).

---

## 4. Nitrolite Contract Addresses

For full Yellow Network integration, deploy or use Nitrolite's contracts:

- **ChannelHub** — Central entry for channel operations
- **ChannelEngine** — State verification and transition validation
- **Custody** — Asset custody (configurable via `CUSTODY_ADDRESS`)
- **Adjudicator** — Dispute resolution (configurable via `ADJUDICATOR_ADDRESS`)

See [Nitrolite deployments](https://github.com/erc7824/nitrolite/tree/main/contracts/deployments) for addresses per chain. RetroPick's relayer uses placeholder defaults (`0x...01`, `0x...02`) if not set; replace with deployed addresses for production.

---

## 5. Deployment Consistency

For Avalanche Fuji (or any network):

1. Deploy via `script/DeployTestnet.s.sol` with `OPERATOR` = address derived from `OPERATOR_PRIVATE_KEY`.
2. Set `CHANNEL_SETTLEMENT_ADDRESS` in relayer `.env` to the deployed ChannelSettlement address.
3. Set `CHAIN_ID` to the deployment chain (e.g. `43113` for Fuji).

---

## 6. References

- [.env.example](../../../../../../apps/relayer/.env.example)
- [nitroliteClient.ts](../../../../../../apps/relayer/src/yellow/nitroliteClient.ts)
- [deploymentAvalancheFuji.md](../../../deployment/deploymentAvalancheFuji.md)
