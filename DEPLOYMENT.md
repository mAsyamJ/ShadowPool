# RetroPick Testnet Deployment

Deployment guide for the CRE + Nitrolite Yellow checkpoint stack to **Tenderly Virtual TestNet** (Worldchain Sepolia).

## Target Network

| Property | Value |
|----------|-------|
| Network | Tenderly Virtual TestNet (Worldchain Sepolia) |
| RPC URL | `https://virtual.worldchain-sepolia.eu.rpc.tenderly.co/41d3ff02-8fa1-4270-aa65-a652be2c6541` |
| Chain ID | 4801 |
| Native Token | ETH |
| Block Explorer | https://worldchain-sepolia-explorer.alchemy.com/ |

## Configuration (from .env)

| Variable | Value | Description |
|----------|-------|-------------|
| `PRIVATE_KEY` | (deployer key) | Wallet that broadcasts deployment |
| `OPERATOR` | `0xbeaA395506D02d20749d8E39ddb996ACe1C85Bfc` | Checkpoint signer for ChannelSettlement |
| `OPERATOR_PRIVATE_KEY` | (same as deployer) | Used by relayer for signing |
| `SETTLEMENT_TOKEN` | `0x0000000000000000000000000000000000000000` | ERC20 collateral; deploy MockERC20 if needed |
| `CHAINLINK_FORWARDER` | `0x0000000000000000000000000000000000000000` | On VT, deploy/mock if receivers enforce it |
| `MIN_CONFIDENCE` | `8000` | Oracle confidence (80% in bps) |
| `PROTOCOL_FEE_BPS` | `250` | Protocol fee 2.5% |
| `LP_FEE_SHARE_BPS` | `1750` | LP share 17.5% |
| `CREATOR_FEE_SHARE_BPS` | `1000` | Creator share 10% |
| `USE_RECEIVER_ALLOWLIST` | `true` | Enforce receiver allowlist |
| `APPROVE_MARKET_REGISTRY_RECEIVER` | `true` | MarketRegistry approved for settlement |
| `EXPECTED_WORKFLOW_NAME` | `retropickV1` | ReceiverTemplate workflow filter |

## Pre-deploy

1. Ensure `.env` is populated (copy from `.env.example`).
2. **Required:** `SETTLEMENT_TOKEN` and `CHAINLINK_FORWARDER` must be non-zero. Deployment reverts otherwise:
   - **SETTLEMENT_TOKEN** – CollateralVault requires a valid ERC20. Deploy a MockERC20 on the VT and mint tokens.
   - **CHAINLINK_FORWARDER** – ReceiverTemplate requires a valid forwarder. On VT, deploy a mock (e.g. a simple contract you control) that can call `onReport` for testing.
3. Fund the deployer wallet with native ETH on the VT for gas.

## Deploy

```bash
cd packages/contracts
source .env  # or export vars manually
forge script script/DeployTestnet.s.sol:DeployTestnet \
  --rpc-url "$RPC_URL" \
  --broadcast \
  --slow
```

# Export private key ke global
export PRIVATE_KEY=$(cast wallet private-key --account rudeus33)
# Deploy with script
forge script script/DeployTestnet.s.sol \
  --rpc-url https://sepolia.base.org/ \
  --broadcast \
  --account rudeus33

`--slow` waits for each transaction to confirm before sending the next, avoiding "replacement transaction underpriced" errors when deploying many contracts.

For a dry run (no broadcast):

```bash
forge script script/DeployTestnet.s.sol:DeployTestnet --rpc-url "$RPC_URL"
```

**"Replacement transaction underpriced"** – Use `--slow` (included above). If you have pending txs from a failed run, either wait for them to confirm or clear and retry.

**Resume partial deployment:**

```bash
forge script script/DeployTestnet.s.sol:DeployTestnet --rpc-url "$RPC_URL" --broadcast --slow --resume
```

## Deployed Contracts

After deployment, record addresses from the script output:

| Contract | Address |
|----------|---------|
| ExecutionLedger | |
| ChannelSettlement | |
| MultiAssetVault | |
| CollateralVault | |
| MarketRegistry | |
| FeeManager | |
| FeePool | |
| TreasuryPool | |
| ReportValidator | |
| CREReceiver | |
| OracleCoordinator | |
| SettlementRouter | |
| MarketPolicy | |
| MarketDraftBoard | |
| DraftClaimManager | |
| LiquidityVaultFactory | |
| CREPublishReceiver | |
| MarketFactory | |

## Post-deploy

### 1. Relayer (`apps/relayer/.env`)

```
CHANNEL_SETTLEMENT_ADDRESS=<ChannelSettlement address from deploy>
OPERATOR_PRIVATE_KEY=<operator key>
```

### 2. CRE Workflows

Configure workflows to use:

- **CREReceiver** – outcome resolution + checkpoint submit
- **CREPublishReceiver** – publish from draft
- **MarketFactory** – CRE feed market creation

### 3. Draft Proposals

Deployer has `AI_ORACLE_ROLE`. Set `AI_ORACLE_ADDRESS` in `.env` and re-run deploy to grant the role to a CRE workflow for automated draft proposals.

## Tenderly Notes

- Virtual TestNets use ephemeral forked state; deployments are not persistent across sessions unless you use Tenderly persistence features.
- No official Chainlink Forwarder on VT; use a mock or disable forwarder checks for testing.
- Fund the deployer wallet with native ETH on the VT for gas.
