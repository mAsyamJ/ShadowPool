# Nitrolite Yellow Integration (Frontend)

**Last updated:** 2026-02-20  
**Audience:** Frontend engineers integrating checkpoint signing and trading UX

---

## What You Need to Know

**Nitrolite Yellow** = off-chain trading + checkpoint settlement. Users trade via the relayer (gasless); checkpoints periodically commit state to the chain. The frontend:

1. Lets users trade via relayer API (or a UI that calls it)
2. Prompts users to **sign checkpoint digests** when the relayer/CRE workflow requests signatures
3. Does **not** call `ChannelSettlement` directly — the CRE workflow delivers payloads via Chainlink Forwarder

**CRE (Chainlink Runtime Environment)** fetches checkpoint payloads from the relayer and sends them on-chain. The relayer builds payloads; CRE delivers them.

---

## Quick Reference

For Nitrolite Yellow (checkpoint-based settlement), the frontend integrates with the **relayer** API and prompts users to sign checkpoints. Key resources:

| Topic | Document |
|-------|----------|
| **Overview** | [RelayerOverview.md](RelayerOverview.md) |
| **Checkpoint format** | [NitroliteYellowCheckpoint.md](NitroliteYellowCheckpoint.md) |
| **API specs** | [RelayerAPI.md](RelayerAPI.md) |
| **Configuration** | [RelayerConfiguration.md](RelayerConfiguration.md) |

---

## Frontend Flow

1. **Trading** — User places order via relayer (`POST /api/trade/buy`, `POST /api/trade/swap`).
2. **Checkpoint ready** — Relayer has session state; CRE/workflow fetches `GET /cre/checkpoints/:sessionId` to get digest and users.
3. **User signs** — Frontend prompts user to sign checkpoint digest (EIP-712). Send signatures to `POST /cre/checkpoints/:sessionId` with `{ userSigs: { [address]: "0x..." } }`.
4. **Relayer returns** — `0x03`-prefixed payload for CRE. Workflow delivers on-chain; frontend does not call contracts.
5. **After finalize** — Subscribe to `CheckpointFinalized`; refresh `ExecutionLedger.positionOf` and vault balances.

---

## Deployment Config (Frontend)

| Config | Source | Use |
|--------|--------|-----|
| `CHANNEL_SETTLEMENT_ADDRESS` | Deploy output | EIP-712 verifying contract for checkpoint signing |
| `OPERATOR` | Relayer-side | Operator key; not used by frontend |
| Relayer URL | `.env` | Base URL for `GET/POST /cre/checkpoints/:sessionId` |

---

## See Also

- [RelayerOverview.md](RelayerOverview.md) — Nitrolite Yellow vs Legacy, lifecycle
- [NitroliteYellowCheckpoint.md](NitroliteYellowCheckpoint.md) — Checkpoint/Delta structs, EIP-712
- [CREOverview.md](../cre/CREOverview.md) — Why relayer goes through CRE
