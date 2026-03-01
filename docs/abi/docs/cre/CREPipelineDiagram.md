# CRE Pipeline Diagram

**Last updated:** 2026-03-01  
**Context:** [CREOverview.md](CREOverview.md) | [CurrentSmartContract.md](../CurrentSmartContract.md)  
**Source:** [CREReceiver.sol](../../../../src/oracle/CREReceiver.sol) lines 31–41, [SettlementRouter.sol](../../../../src/core/SettlementRouter.sol) lines 111–143

---

## 1. Full Pipeline Topology

```mermaid
flowchart TB
    subgraph external [External]
        DON[CRE Workflow DON]
        Relayer[Relayer API]
    end

    subgraph ingress [Ingress]
        FWD[Chainlink Forwarder]
        CR[CREReceiver]
        CPR[CREPublishReceiver]
    end

    subgraph routing [Routing]
        OC[OracleCoordinator]
        SR[SettlementRouter]
    end

    subgraph targets [On-Chain Targets]
        MR[MarketRegistry]
        PM[PoolMarketLegacy]
        CS[ChannelSettlement]
        MF[MarketFactory]
    end

    DON -->|writeReport| FWD
    Relayer -->|HTTP| DON
    FWD --> CR
    FWD --> CPR
    CR --> OC --> SR
    SR -->|settleMarket 0x01| MR
    SR -->|settleMarket 0x01| PM
    SR -->|finalizeSession 0x03| CS
    CPR --> MF
```

---

## 2. Execution Lifecycle (Generic)

```
Trigger (cron/HTTP/EVM) → Callback runs on DON
  → Capability calls (HTTP fetch, chain read)
  → Consensus across DON nodes
  → evmClient.writeReport(payload)
  → Forwarder receives tx
  → Forwarder calls receiver.onReport(metadata, payload)
  → Receiver._processReport routes by prefix
  → Coordinator/Router dispatch to target contract
```

---

## 3. Outcome Flow (Market Resolution)

```mermaid
sequenceDiagram
    participant Oracle as Oracle Data Source
    participant CRE as CRE Workflow
    participant FWD as Forwarder
    participant CR as CREReceiver
    participant OC as OracleCoordinator
    participant SR as SettlementRouter
    participant MR as MarketRegistry

    Oracle --> CRE: Outcome data
    Note over CRE: encode(market, marketId, outcomeIndex, confidence)
    CRE --> FWD: writeReport(payload) [no prefix]
    FWD --> CR: onReport(payload)
    CR --> OC: submitResult(...)
    OC --> SR: settleMarket(market, marketId, outcomeIndex, confidence)
    SR --> SR: Build 0x01 || abi.encode(marketId, outcomeIndex, confidence)
    SR --> MR: onReport("", 0x01 || ...)
    MR --> MR: _doResolve(marketId, outcomeIndex, confidence)
```

**Relayer endpoints used:** None (outcome flow does not use relayer).

---

## 4. Checkpoint Flow (Session Settlement)

```mermaid
sequenceDiagram
    participant User
    participant Relayer
    participant CRE as CRE Workflow
    participant FWD as Forwarder
    participant CR as CREReceiver
    participant SR as SettlementRouter
    participant CS as ChannelSettlement

    User->>Relayer: Trade (POST /api/trade/*)
    Note over Relayer: Session state updated
    CRE->>Relayer: GET /cre/checkpoints/:sessionId
    Relayer->>CRE: digest, users, deltas
    CRE->>User: Request signatures (via frontend or signing service)
    User->>CRE: userSigs
    CRE->>Relayer: POST /cre/checkpoints/:sessionId { userSigs }
    Relayer->>CRE: 0x03 || payload
    CRE->>FWD: writeReport(payload)
    FWD->>CR: onReport(payload)
    CR->>SR: submitSession → finalizeSession
    SR->>CS: submitCheckpointFromPayload
    Note over CS: 30 min challenge window
    Note over CS: Anyone: finalizeCheckpoint
```

**Relayer endpoints used:**

| Endpoint | Purpose |
|----------|---------|
| `GET /cre/checkpoints` | List sessions with pending checkpoints |
| `GET /cre/checkpoints/:sessionId` | Get digest, users, deltas for signature collection |
| `POST /cre/checkpoints/:sessionId` | Build full payload with operator + user sigs |

See [RelayerAPI.md](../relayer/RelayerAPI.md) for full API details.

---

## 5. Publish Flow (Create Market from Draft)

```mermaid
sequenceDiagram
    participant Creator
    participant CRE as CRE Workflow
    participant FWD as Forwarder
    participant CPR as CREPublishReceiver
    participant MF as MarketFactory
    participant MR as MarketRegistry

    Creator->>CRE: Request publish (EIP-712 PublishFromDraft signed)
    Note over CRE: encode(draftId, creator, params, claimerSig)
    CRE --> FWD: writeReport(0x04 || payload)
    Note over CRE: Workflow must target CREPublishReceiver
    FWD --> CPR: onReport(payload)
    CPR --> CPR: Verify DraftStatus.Claimed, creator == claimer
    CPR --> CPR: Verify EIP-712 PublishFromDraft signature
    CPR --> MF: createFromDraft(draftId, creator, params)
    MF --> MR: create*ForWithFullParams, setLiquidityVault, etc.
```

**Relayer endpoints used:** None (publish flow uses creator signature; workflow targets CREPublishReceiver).

---

## 6. Forwarder Routing

The Chainlink Forwarder delivers reports to a **receiver address**. Each CRE workflow is configured with:

- **Target chain** and **Forwarder contract address**
- **Receiver address** (CREReceiver or CREPublishReceiver)

| Flow | Workflow targets | Receiver |
|------|------------------|----------|
| Outcome | CREReceiver | CREReceiver |
| Checkpoint | CREReceiver | CREReceiver |
| Publish | CREPublishReceiver | CREPublishReceiver |

The report **prefix** (0x03, 0x04) is used by the receiver for internal routing, not by the Forwarder. The Forwarder delivers to whichever receiver the workflow is configured for.

---

## 7. References

- [CREOverview.md](CREOverview.md) — CRE concepts, trust model
- [CREReportFormats.md](CREReportFormats.md) — Payload schemas
- [CREContractReference.md](CREContractReference.md) — Contract methods and guards
- [RelayerArchitecture.md](../relayer/RelayerArchitecture.md) — Relayer role and lifecycle
