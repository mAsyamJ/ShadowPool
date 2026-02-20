# Smart Contract Integration Documentation

**Last updated:** 2026-02-20  
**Purpose:** ABI artifacts and integration documentation for RetroPick smart contracts.

---

## 1. Overview

The `.docs/abi/` directory contains:

- **JSON ABIs** — Per-contract ABI files for frontend and tooling
- **docs/** — Integration guides, architecture, and development context

---

## 2. Documentation Map

| Path | Description |
|------|-------------|
| [CurrentSmartContract.md](CurrentSmartContract.md) | Authoritative architecture, topology, contract inventory, data models, flows |
| [frontend/](frontend/) | Frontend integration per contract; [Frontend.md](frontend/Frontend.md), [AppFlow.md](frontend/AppFlow.md) |
| [cre/](cre/) | **Chainlink CRE** — workflow architecture, report formats, evmClient.writeReport, trigger-callback model |
| [relayer/](relayer/) | **Nitrolite Yellow** — Nitrolite/ERC-7824, LS-LMSR pricing, session state, relayer API, checkpoint format |
| [IntegrationMatrix.md](IntegrationMatrix.md) | Contract → report type → CRE path mapping |
| [DevelopmentContext.md](DevelopmentContext.md) | Setup, build, test, deploy, relayer, wiring |
| [DataStructures.md](DataStructures.md) | Checkpoint, Delta, Draft, Market structs; enums |

---

## 3. Key Flows

| Flow | Path |
|------|------|
| **Curated draft → Publish** | [AppFlow.md](frontend/AppFlow.md) §2, [CurrentSmartContract.md](CurrentSmartContract.md) §6.2 |
| **Nitrolite Yellow checkpoint** | [RelayerOverview.md](relayer/RelayerOverview.md), [CREWorkflowIntegration.md](cre/CREWorkflowIntegration.md) |
| **Oracle resolution → Redeem** | [CurrentSmartContract.md](CurrentSmartContract.md) §6.1, [AppFlow.md](frontend/AppFlow.md) §3.8 |

---

## 4. References

- [e2eAvalanceFujiTest.md](../../e2e/e2eAvalanceFujiTest.md) — E2E test flows, Nitrolite Yellow rationale
- [deploymentAvalancheFuji.md](../../deployment/deploymentAvalancheFuji.md) — Fuji contract addresses
