Below is a **ready-to-paste deployment doc** for your **Avalanche Fuji (Chain ID 43113)** deployment, including **Snowtrace block explorer links** + a **verification checklist + commands** (Foundry).

---

# RetroPick – Fuji Deployment (43113)

## Network

* Chain: **Avalanche Fuji (C-Chain)**
* Chain ID: **43113**
* Explorer: **Snowtrace Testnet** (use links below)

Deployer:

* `0x38A8AB6EE17EB531d86eb877e56005587bC078e7`

---

## Deployed Contracts (Snowtrace links)

Execution lane

* **ExecutionLedger**: `0xE4d4187d6Ca2c4eA36A05d3eb61a7A79da7F6D25`
  Explorer: `https://testnet.snowtrace.io/address/0xE4d4187d6Ca2c4eA36A05d3eb61a7A79da7F6D25`
* **ChannelSettlement**: `0xa1F7673D2677FB9e48C7a6295DD7cF44F8c0A212`
  Explorer: `https://testnet.snowtrace.io/address/0xa1F7673D2677FB9e48C7a6295DD7cF44F8c0A212`
* **MultiAssetVault**: `0xf780caB68DE9800fd6b8ee6AEfc0b06A5F3181dB`
  Explorer: `https://testnet.snowtrace.io/address/0xf780caB68DE9800fd6b8ee6AEfc0b06A5F3181dB`
* **CollateralVault**: `0xe1557c8f239752A22278a5c55f0CB28b041D9fcd`
  Explorer: `https://testnet.snowtrace.io/address/0xe1557c8f239752A22278a5c55f0CB28b041D9fcd`
* **MarketRegistry**: `0xdB8d890B9aE6A40D2838A508F7D2126cb42a36E4`
  Explorer: `https://testnet.snowtrace.io/address/0xdB8d890B9aE6A40D2838A508F7D2126cb42a36E4`

Fees

* **FeeManager**: `0xB9C04B35C64dc263809DaeA3233de0855b44a82D`
  Explorer: `https://testnet.snowtrace.io/address/0xB9C04B35C64dc263809DaeA3233de0855b44a82D`
* **FeePool**: `0x59d2B7563bC7b80c3EcE9A3E616441e68ca158A6`
  Explorer: `https://testnet.snowtrace.io/address/0x59d2B7563bC7b80c3EcE9A3E616441e68ca158A6`
* **TreasuryPool**: `0x1723701b8143537e023b9C6165dAeF9A67125d43`
  Explorer: `https://testnet.snowtrace.io/address/0x1723701b8143537e023b9C6165dAeF9A67125d43`

Oracle + routing

* **ReportValidator**: `0xC6c31b73CE71B42aB45dd017061fcd5D9620a1bE`
  Explorer: `https://testnet.snowtrace.io/address/0xC6c31b73CE71B42aB45dd017061fcd5D9620a1bE`
* **CREReceiver**: `0xf427BC9e8C7004F394fa06147bf42aad1D516FdF`
  Explorer: `https://testnet.snowtrace.io/address/0xf427BC9e8C7004F394fa06147bf42aad1D516FdF`
* **OracleCoordinator**: `0xA30Fa013c5CAe93C2e75129ceA669635e011d6F8`
  Explorer: `https://testnet.snowtrace.io/address/0xA30Fa013c5CAe93C2e75129ceA669635e011d6F8`
* **SettlementRouter**: `0x789daEE98ac0C8EEe220Dd768f0e2A05C66B983E`
  Explorer: `https://testnet.snowtrace.io/address/0x789daEE98ac0C8EEe220Dd768f0e2A05C66B983E`

Curation / publishing

* **MarketPolicy**: `0x98f399081CbDB2eeB66c8c3c51F5fF592A045396`
  Explorer: `https://testnet.snowtrace.io/address/0x98f399081CbDB2eeB66c8c3c51F5fF592A045396`
* **MarketDraftBoard**: `0xa1A31B61748252D7E1f15B2F74de0ce99f1a296f`
  Explorer: `https://testnet.snowtrace.io/address/0xa1A31B61748252D7E1f15B2F74de0ce99f1a296f`
* **DraftClaimManager**: `0x1Ccccc54e0cE928b3FC04aA2Ed4E012E7EaAdDe9`
  Explorer: `https://testnet.snowtrace.io/address/0x1Ccccc54e0cE928b3FC04aA2Ed4E012E7EaAdDe9`
* **LiquidityVaultFactory**: `0xd895dD8547A0fC6214A7ce9D74B49F9b0601C362`
  Explorer: `https://testnet.snowtrace.io/address/0xd895dD8547A0fC6214A7ce9D74B49F9b0601C362`
* **MarketFactory**: `0x68D0e961FdFAF031323099a4680847321eFBb7e5`
  Explorer: `https://testnet.snowtrace.io/address/0x68D0e961FdFAF031323099a4680847321eFBb7e5`
* **CREPublishReceiver**: `0xEF0aebe656c82A6d070f904c0c31EE1B0B81fBB2`
  Explorer: `https://testnet.snowtrace.io/address/0xEF0aebe656c82A6d070f904c0c31EE1B0B81fBB2`

---

## Post-deploy wiring (relayer)

Set in `apps/relayer/.env`:

* `CHANNEL_SETTLEMENT_ADDRESS=0xa1F7673D2677FB9e48C7a6295DD7cF44F8c0A212`
* `OPERATOR_PRIVATE_KEY=<same key used for OPERATOR address>`

---

# Contract Verification (Snowtrace)

Snowtrace testnet supports an **Etherscan-style API**, so Foundry verification works the same way.

## 1) Prereqs

1. Get a **Snowtrace API Key** (testnet) and export:

```bash
export ETHERSCAN_API_KEY="YOUR_SNOWTRACE_API_KEY"
```

2. Make sure you compile with the **same settings** you deployed with:

* same Solidity version
* same optimizer runs
* same `viaIR` (if used)
  Run:

```bash
forge build
```

## 2) Add Foundry etherscan config (recommended)

In `foundry.toml`, add:

```toml
[etherscan]
avalanche-fuji = { key = "${ETHERSCAN_API_KEY}", chain = 43113, url = "https://api-testnet.snowtrace.io/api" }
```

Now you can verify with `--etherscan-api-key` omitted (it reads env).

## 3) Verify each contract

### A) Contracts with NO constructor args

These can be verified directly:

```bash
forge verify-contract --chain-id 43113 0xA30Fa013c5CAe93C2e75129ceA669635e011d6F8 src/oracle/OracleCoordinator.sol:OracleCoordinator
forge verify-contract --chain-id 43113 0x789daEE98ac0C8EEe220Dd768f0e2A05C66B983E src/core/SettlementRouter.sol:SettlementRouter
forge verify-contract --chain-id 43113 0x59d2B7563bC7b80c3EcE9A3E616441e68ca158A6 src/fees/FeePool.sol:FeePool
forge verify-contract --chain-id 43113 0x1723701b8143537e023b9C6165dAeF9A67125d43 src/fees/TreasuryPool.sol:TreasuryPool
forge verify-contract --chain-id 43113 0x98f399081CbDB2eeB66c8c3c51F5fF592A045396 src/curation/MarketPolicy.sol:MarketPolicy
forge verify-contract --chain-id 43113 0xa1A31B61748252D7E1f15B2F74de0ce99f1a296f src/curation/MarketDraftBoard.sol:MarketDraftBoard
```

### B) Contracts WITH constructor args

Use your `.env.fuji` so args match exactly.

Load env (important):

```bash
source .env.fuji
```

Then verify using `--constructor-args` built via `cast abi-encode`:

**ReportValidator(minConfidence)**

```bash
ARGS=$(cast abi-encode "constructor(uint16)" "$MIN_CONFIDENCE")
forge verify-contract --chain-id 43113 0xC6c31b73CE71B42aB45dd017061fcd5D9620a1bE src/oracle/ReportValidator.sol:ReportValidator --constructor-args "$ARGS"
```

**FeeManager(protocolFeeBps)**

```bash
ARGS=$(cast abi-encode "constructor(uint16)" "$PROTOCOL_FEE_BPS")
forge verify-contract --chain-id 43113 0xB9C04B35C64dc263809DaeA3233de0855b44a82D src/fees/FeeManager.sol:FeeManager --constructor-args "$ARGS"
```

**ExecutionLedger(address)**

```bash
ARGS=$(cast abi-encode "constructor(address)" "0x0000000000000000000000000000000000000000")
forge verify-contract --chain-id 43113 0xE4d4187d6Ca2c4eA36A05d3eb61a7A79da7F6D25 src/execution/ExecutionLedger.sol:ExecutionLedger --constructor-args "$ARGS"
```

**MultiAssetVault(address)**

```bash
ARGS=$(cast abi-encode "constructor(address)" "0x0000000000000000000000000000000000000000")
forge verify-contract --chain-id 43113 0xf780caB68DE9800fd6b8ee6AEfc0b06A5F3181dB src/execution/MultiAssetVault.sol:MultiAssetVault --constructor-args "$ARGS"
```

**CollateralVault(settlementToken, address(0))**

```bash
ARGS=$(cast abi-encode "constructor(address,address)" "$SETTLEMENT_TOKEN" "0x0000000000000000000000000000000000000000")
forge verify-contract --chain-id 43113 0xe1557c8f239752A22278a5c55f0CB28b041D9fcd src/execution/CollateralVault.sol:CollateralVault --constructor-args "$ARGS"
```

**ChannelSettlement(collateralVault, ledger, operator)**

```bash
ARGS=$(cast abi-encode "constructor(address,address,address)" \
  0xe1557c8f239752A22278a5c55f0CB28b041D9fcd \
  0xE4d4187d6Ca2c4eA36A05d3eb61a7A79da7F6D25 \
  "$OPERATOR")
forge verify-contract --chain-id 43113 0xa1F7673D2677FB9e48C7a6295DD7cF44F8c0A212 src/execution/ChannelSettlement.sol:ChannelSettlement --constructor-args "$ARGS"
```

**MarketRegistry(collateralVault, ledger)**

```bash
ARGS=$(cast abi-encode "constructor(address,address)" \
  0xe1557c8f239752A22278a5c55f0CB28b041D9fcd \
  0xE4d4187d6Ca2c4eA36A05d3eb61a7A79da7F6D25)
forge verify-contract --chain-id 43113 0xdB8d890B9aE6A40D2838A508F7D2126cb42a36E4 src/core/MarketRegistry.sol:MarketRegistry --constructor-args "$ARGS"
```

**CREReceiver(forwarder, oracleCoordinator)**

```bash
ARGS=$(cast abi-encode "constructor(address,address)" "$CHAINLINK_FORWARDER" 0xA30Fa013c5CAe93C2e75129ceA669635e011d6F8)
forge verify-contract --chain-id 43113 0xf427BC9e8C7004F394fa06147bf42aad1D516FdF src/oracle/CREReceiver.sol:CREReceiver --constructor-args "$ARGS"
```

**DraftClaimManager(draftBoard)**

```bash
ARGS=$(cast abi-encode "constructor(address)" 0xa1A31B61748252D7E1f15B2F74de0ce99f1a296f)
forge verify-contract --chain-id 43113 0x1Ccccc54e0cE928b3FC04aA2Ed4E012E7EaAdDe9 src/curation/DraftClaimManager.sol:DraftClaimManager --constructor-args "$ARGS"
```

**LiquidityVaultFactory(channelSettlement)**

```bash
ARGS=$(cast abi-encode "constructor(address)" 0xa1F7673D2677FB9e48C7a6295DD7cF44F8c0A212)
forge verify-contract --chain-id 43113 0xd895dD8547A0fC6214A7ce9D74B49F9b0601C362 src/curation/LiquidityVaultFactory.sol:LiquidityVaultFactory --constructor-args "$ARGS"
```

**MarketFactory(forwarder, marketRegistry)**

```bash
ARGS=$(cast abi-encode "constructor(address,address)" "$CHAINLINK_FORWARDER" 0xdB8d890B9aE6A40D2838A508F7D2126cb42a36E4)
forge verify-contract --chain-id 43113 0x68D0e961FdFAF031323099a4680847321eFBb7e5 src/core/MarketFactory.sol:MarketFactory --constructor-args "$ARGS"
```

**CREPublishReceiver(forwarder, draftBoard, draftClaimManager, marketPolicy, marketFactory)**

```bash
ARGS=$(cast abi-encode "constructor(address,address,address,address,address)" \
  "$CHAINLINK_FORWARDER" \
  0xa1A31B61748252D7E1f15B2F74de0ce99f1a296f \
  0x1Ccccc54e0cE928b3FC04aA2Ed4E012E7EaAdDe9 \
  0x98f399081CbDB2eeB66c8c3c51F5fF592A045396 \
  0x68D0e961FdFAF031323099a4680847321eFBb7e5)
forge verify-contract --chain-id 43113 0xEF0aebe656c82A6d070f904c0c31EE1B0B81fBB2 src/curation/CREPublishReceiver.sol:CREPublishReceiver --constructor-args "$ARGS"
```

---

## If verification fails

Most common causes:

* different optimizer runs / viaIR settings vs deployment
* wrong constructor args (especially forwarder/operator/settlement token)
* wrong source path / contract name

Quick recompile sanity:

```bash
forge clean && forge build
```

---

If you paste your `foundry.toml` (optimizer/viaIR) and the exact `CHAINLINK_FORWARDER`, `OPERATOR`, `SETTLEMENT_TOKEN` you used on this successful run, I can tailor the verification commands to be 1:1 guaranteed.
