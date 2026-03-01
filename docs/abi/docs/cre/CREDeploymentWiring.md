# CRE Deployment Wiring Checklist

**Last updated:** 2026-03-01  
**Context:** [CurrentSmartContract.md](../CurrentSmartContract.md) §14.2 | [CREOverview.md](CREOverview.md)

---

## 1. Forwarder (Per Chain)

| Variable | Description |
|----------|-------------|
| `CHAINLINK_FORWARDER` | Chainlink Forwarder contract address for the target chain |

**Chain-specific:** Use simulation forwarder for local `cre workflow simulate`; production forwarder for DON-deployed workflows.

Example (Avalanche Fuji):

- Simulation: `CRE_FORWARDER_SIM_FUJI`
- Production: `CRE_FORWARDER_PROD_FUJI`

---

## 2. Receiver Constructor Args

### 2.1 CREReceiver

```solidity
constructor(address forwarderAddress, address coordinator)
```

| Param | Value |
|-------|-------|
| forwarderAddress | `CHAINLINK_FORWARDER` |
| coordinator | OracleCoordinator address |

### 2.2 CREPublishReceiver

```solidity
constructor(
    address forwarderAddress,
    address draftBoard_,
    address draftClaimManager_,
    address marketPolicy_,
    address marketFactory_
)
```

| Param | Value |
|-------|-------|
| forwarderAddress | `CHAINLINK_FORWARDER` |
| draftBoard_ | MarketDraftBoard address |
| draftClaimManager_ | DraftClaimManager address |
| marketPolicy_ | MarketPolicy address |
| marketFactory_ | MarketFactory address |

---

## 3. Coordinator / Router Wiring

| Call | Target | Purpose |
|------|--------|---------|
| `OracleCoordinator.setCreReceiver(CREReceiver)` | CREReceiver | Only CREReceiver can call submitResult/submitSession |
| `OracleCoordinator.setSettlementRouter(SettlementRouter)` | SettlementRouter | Route outcomes and sessions |
| `OracleCoordinator.setReportValidator(ReportValidator)` | ReportValidator | Optional; validate confidence for outcomes |
| `SettlementRouter.setOracleCoordinator(OracleCoordinator)` | OracleCoordinator | Only coordinator can call settleMarket/finalizeSession |
| `SettlementRouter.setChannelSettlement(ChannelSettlement)` | ChannelSettlement | Checkpoint path (V3) |
| `SettlementRouter.setSessionFinalizer(SessionFinalizer)` | SessionFinalizer | Legacy path (optional) |
| `SettlementRouter.setMarketReceiverApproved(MarketRegistry, true)` | MarketRegistry | Allow outcome settlement if useReceiverAllowlist |
| `MarketRegistry.setSettlementRouter(SettlementRouter)` | SettlementRouter | Require router for onReport |

---

## 4. Relayer Environment

| Variable | Description |
|----------|-------------|
| `CHANNEL_SETTLEMENT_ADDRESS` | ChannelSettlement contract address |
| `OPERATOR_PRIVATE_KEY` | Key for operator; must match ChannelSettlement.operator |
| `CHAIN_ID` | Chain ID for EIP-712 checkpoint signing |
| `RPC_URL` | Optional; for finalizer if relayer submits finalize tx |

---

## 5. Workflow Configuration

| Config | Description |
|--------|-------------|
| **relayerUrl** | Base URL of relayer API (e.g. `http://localhost:8790`) |
| **Chain** | Target chain ID and RPC |
| **Forwarder** | Same as `CHAINLINK_FORWARDER` |
| **Receiver (checkpoint/outcome)** | CREReceiver address |
| **Receiver (publish)** | CREPublishReceiver address |

**Important:** Checkpoint and outcome workflows target **CREReceiver**. Publish workflow targets **CREPublishReceiver**.

---

## 6. Optional ReceiverTemplate Metadata

For workflow identity validation (restrict which workflows can send reports):

| Setter | Value | Purpose |
|--------|-------|---------|
| `setExpectedAuthor(address)` | Workflow owner | Only this author's workflows |
| `setExpectedWorkflowId(bytes32)` | Workflow ID | Only this workflow |
| `setExpectedWorkflowName(string)` | Workflow name | Only this name (requires author) |

Apply to CREReceiver, CREPublishReceiver, MarketFactory as needed.

---

## 7. Deployment Order (Typical)

1. Deploy vaults, OutcomeToken1155, MarketRiskManager, ChannelSettlement, MarketRegistry
2. Wire V3: setChannelSettlement, setOutcomeToken, setRiskManager, setMarketRegistry, etc.
3. Deploy OracleCoordinator, SettlementRouter, CREReceiver
4. Wire coordinator: setCreReceiver, setSettlementRouter, setReportValidator
5. Wire router: setOracleCoordinator, setChannelSettlement, setMarketReceiverApproved
6. Wire MarketRegistry: setSettlementRouter
7. Deploy curation lane: DraftBoard, DraftClaimManager, LiquidityVaultFactory, MarketFactory, CREPublishReceiver
8. Wire MarketFactory: setPublishReceiverApproved(CREPublishReceiver)
9. Configure ReceiverTemplate metadata (optional)

---

## 8. Post-Deploy Checklist

- [ ] Relayer `.env`: `CHANNEL_SETTLEMENT_ADDRESS`, `OPERATOR_PRIVATE_KEY`, `CHAIN_ID`
- [ ] CRE checkpoint workflow: `relayerUrl`, CREReceiver address, Forwarder
- [ ] CRE outcome workflow: Oracle data source, CREReceiver address, market allowlist
- [ ] CRE publish workflow: CREPublishReceiver address (separate from CREReceiver)
- [ ] Verify `ChannelSettlement.operator` matches relayer `OPERATOR_PRIVATE_KEY` derived address

---

## 9. References

- [script/DeployBetaTestnet.s.sol](../../script/DeployBetaTestnet.s.sol) — Full deploy script
- [.env.example](../../.env.example) — Env template
- [CurrentSmartContract.md](../CurrentSmartContract.md) §14.2 — Concrete wiring requirements
