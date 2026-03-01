# Development Context

**Last updated:** 2026-02-20  
**Context:** [CurrentSmartContract.md](CurrentSmartContract.md) | [e2eAvalanceFujiTest.md](../../e2e/e2eAvalanceFujiTest.md)

---

## 1. Setup

### 1.1 Prerequisites

- **Foundry** — `forge`, `cast`, `anvil`
- **Node.js / Bun** — For relayer (`apps/relayer`)

### 1.2 Contract Package

```bash
cd packages/contracts
forge install   # if needed
forge build
```

### 1.3 DeployTestnet Environment

Required env vars for `script/DeployTestnet.s.sol`:

| Variable | Description |
|----------|-------------|
| `OPERATOR` | Operator address (checkpoint signer); used by ChannelSettlement |
| `SETTLEMENT_TOKEN` | ERC20 address for collateral (e.g. USDC test token) |
| `CHAINLINK_FORWARDER` | Chainlink Forwarder contract for target chain |
| `MIN_CONFIDENCE` | ReportValidator threshold (e.g. 8000 = 80%) |
| `PROTOCOL_FEE_BPS` | Total fee cap (e.g. 100 = 1%) |
| `LP_FEE_SHARE_BPS` | LP share of fee (e.g. 2000 = 20%) |
| `CREATOR_FEE_SHARE_BPS` | Creator share of fee (e.g. 1000 = 10%) |

Optional: `USE_RECEIVER_ALLOWLIST`, `APPROVE_MARKET_REGISTRY_RECEIVER`, `EXPECTED_WORKFLOW_AUTHOR`, `EXPECTED_WORKFLOW_ID`, `EXPECTED_WORKFLOW_NAME`.

---

## 2. Build and Test

```bash
# Build
forge build

# All tests
forge test

# E2E only (DeployTestnet topology)
forge test --match-contract E2EDeployTestnetTest

# With verbosity
forge test -vvv
```

E2E tests validate the full production path: curated draft → claimAndSeed → publish → Nitrolite Yellow checkpoint → oracle resolution → redeem.

---

## 3. Deploy

```bash
source .env.fuji   # or your network env
forge script script/DeployTestnet.s.sol:DeployTestnet --rpc-url $RPC_URL --broadcast
```

Deploy script: [script/DeployTestnet.s.sol](../../../script/DeployTestnet.s.sol) — CRE + Nitrolite Yellow stack; no PoolMarketLegacy or SessionFinalizer.

---

## 4. Relayer

```bash
cd ../../apps/relayer   # from packages/contracts
bun install
bun run dev
```

**Required for Nitrolite Yellow:**

- `CHANNEL_SETTLEMENT_ADDRESS` — Deployed ChannelSettlement
- `OPERATOR_PRIVATE_KEY` — Key for operator; must match ChannelSettlement.operator
- `CHAIN_ID` — Deployment chain (e.g. 43113 for Fuji)

See [RelayerConfiguration.md](relayer/RelayerConfiguration.md).

---

## 5. Contract Wiring (High-Level)

From [CurrentSmartContract.md](CurrentSmartContract.md) §14.2:

| From | To | Link |
|------|-----|-----|
| MarketRegistry | MarketFactory, SettlementRouter, MultiAssetVault | setMarketFactory, setSettlementRouter, setMultiAssetVault |
| ExecutionLedger | ChannelSettlement | setChannelSettlement |
| MultiAssetVault | ChannelSettlement, MarketRegistry | setChannelSettlement, setMarketRegistry |
| CollateralVault | ChannelSettlement, MarketRegistry | setChannelSettlement, setMarketRegistry |
| ChannelSettlement | MarketRegistry, MultiAssetVault, FeeManager, FeePool | setMarketRegistry, setMultiAssetVault, setFeeManager, setFeePool |
| OracleCoordinator | CREReceiver, SettlementRouter, ReportValidator | setCreReceiver, setSettlementRouter, setReportValidator |
| SettlementRouter | OracleCoordinator, ChannelSettlement | setOracleCoordinator, setChannelSettlement |
| MarketFactory | MarketRegistry, MarketDraftBoard, DraftClaimManager | setMarketRegistry, setDraftBoard, setDraftClaimManager |
| LiquidityVaultFactory | ChannelSettlement | constructor + setChannelSettlement |
| DraftClaimManager | LiquidityVaultFactory | setLiquidityVaultFactory |
| MarketDraftBoard | DraftClaimManager, MarketFactory (PUBLISH_CALLER_ROLE) | setDraftClaimManager, grant role |

---

## 6. Key Source Paths

| Path | Contents |
|------|----------|
| `src/core/` | MarketRegistry, MarketFactory, SettlementRouter |
| `src/oracle/` | CREReceiver, OracleCoordinator, ReportValidator |
| `src/curation/` | MarketDraftBoard, DraftClaimManager, CREPublishReceiver, LiquidityVaultFactory |
| `src/execution/` | ChannelSettlement, ExecutionLedger, CollateralVault, MultiAssetVault |
| `src/fees/` | FeeManager, FeePool, TreasuryPool |

---

## 7. References

- [deploymentAvalancheFuji.md](../../deployment/deploymentAvalancheFuji.md) — Fuji addresses
- [e2eAvalanceFujiTest.md](../../e2e/e2eAvalanceFujiTest.md) — E2E flow and Nitrolite Yellow
