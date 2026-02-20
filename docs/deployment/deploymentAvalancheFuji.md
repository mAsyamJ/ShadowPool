# RetroPick — Avalanche Fuji Deployment (43113)

RetroPick is a modular prediction-market settlement and publishing stack. It is designed to keep the protocol primitives on-chain (custody, settlement, fees, registry, publishing) while remaining compatible with offchain orchestration (e.g., Chainlink CRE workflows) that can propose drafts, trigger publishing, and feed resolution inputs.

This document describes the Avalanche Fuji deployment of the RetroPick core contracts, with verified source code on Snowscan.

---

## Network

- Chain: Avalanche Fuji (C-Chain)
- Chain ID: 43113
- Native: AVAX
- Explorer: Snowscan (Fuji)

RPC
- https://avalanche-fuji.infura.io/v3/abecf4484c4043068cff2b738795c35a

Deployer / Operator
- 0x38A8AB6EE17EB531d86eb877e56005587bC078e7

Compiler
- v0.8.24+commit.e11b9ed9

---

## Verified Contracts (Snowscan)

All links below point to verified contracts on:
https://testnet.snowscan.xyz

### Execution lane (custody + settlement)

- ExecutionLedger  
  0xE4d4187d6Ca2c4eA36A05d3eb61a7A79da7F6D25  
  https://testnet.snowscan.xyz/address/0xe4d4187d6ca2c4ea36a05d3eb61a7a79da7f6d25

- CollateralVault  
  0xe1557c8f239752A22278a5c55f0CB28b041D9fcd  
  https://testnet.snowscan.xyz/address/0xe1557c8f239752a22278a5c55f0cb28b041d9fcd

- MultiAssetVault  
  0xf780caB68DE9800fd6b8ee6AEfc0b06A5F3181dB  
  https://testnet.snowscan.xyz/address/0xf780cab68de9800fd6b8ee6aefc0b06a5f3181db

- ChannelSettlement  
  0xa1F7673D2677FB9e48C7a6295DD7cF44F8c0A212  
  https://testnet.snowscan.xyz/address/0xa1f7673d2677fb9e48c7a6295dd7cf44f8c0a212

- SettlementRouter  
  0x789daEE98ac0C8EEe220Dd768f0e2A05C66B983E  
  https://testnet.snowscan.xyz/address/0x789daee98ac0c8eee220dd768f0e2a05c66b983e

- MarketRegistry  
  0xdB8d890B9aE6A40D2838A508F7D2126cb42a36E4  
  https://testnet.snowscan.xyz/address/0xdb8d890b9ae6a40d2838a508f7d2126cb42a36e4

### Fees

- FeeManager  
  0xB9C04B35C64dc263809DaeA3233de0855b44a82D  
  https://testnet.snowscan.xyz/address/0xb9c04b35c64dc263809daea3233de0855b44a82d

- FeePool  
  0x59d2B7563bC7b80c3EcE9A3E616441e68ca158A6  
  https://testnet.snowscan.xyz/address/0x59d2b7563bc7b80c3ece9a3e616441e68ca158a6

- TreasuryPool  
  0x1723701b8143537e023b9C6165dAeF9A67125d43  
  https://testnet.snowscan.xyz/address/0x1723701b8143537e023b9c6165daef9a67125d43

### Oracle + routing (CRE integration + validation)

- ReportValidator  
  0xC6c31b73CE71B42aB45dd017061fcd5D9620a1bE  
  https://testnet.snowscan.xyz/address/0xc6c31b73ce71b42ab45dd017061fcd5d9620a1be

- OracleCoordinator  
  0xA30Fa013c5CAe93C2e75129ceA669635e011d6F8  
  https://testnet.snowscan.xyz/address/0xa30fa013c5cae93c2e75129cea669635e011d6f8

- CREReceiver  
  0xf427BC9e8C7004F394fa06147bf42aad1D516FdF  
  https://testnet.snowscan.xyz/address/0xf427bc9e8c7004f394fa06147bf42aad1d516fdf

### Curation / publishing (drafts → claims → market creation)

- MarketPolicy  
  0x98f399081CbDB2eeB66c8c3c51F5fF592A045396  
  https://testnet.snowscan.xyz/address/0x98f399081cbdb2eeb66c8c3c51f5ff592a045396

- MarketDraftBoard  
  0xa1A31B61748252D7E1f15B2F74de0ce99f1a296f  
  https://testnet.snowscan.xyz/address/0xa1a31b61748252d7e1f15b2f74de0ce99f1a296f

- DraftClaimManager  
  0x1Ccccc54e0cE928b3FC04aA2Ed4E012E7EaAdDe9  
  https://testnet.snowscan.xyz/address/0x1ccccc54e0ce928b3fc04aa2ed4e012e7eaadde9

- LiquidityVaultFactory  
  0xd895dD8547A0fC6214A7ce9D74B49F9b0601C362  
  https://testnet.snowscan.xyz/address/0xd895dd8547a0fc6214a7ce9d74b49f9b0601c362

- MarketFactory  
  0x68D0e961FdFAF031323099a4680847321eFBb7e5  
  https://testnet.snowscan.xyz/address/0x68d0e961fdfaf031323099a4680847321efbb7e5

- CREPublishReceiver  
  0xEF0aebe656c82A6d070f904c0c31EE1B0B81fBB2  
  https://testnet.snowscan.xyz/address/0xef0aebe656c82a6d070f904c0c31ee1b0b81fbb2

---

## Deployment Parameters (Fuji)

These values are required to reproduce verification and to understand the wiring.

Settlement token (Fuji USDC)
- SETTLEMENT_TOKEN=0x5425890298aed601595a70AB815c96711a31Bc65

Chainlink CRE forwarder (Fuji)
- CHAINLINK_FORWARDER=0x2e7371a5d032489e4f60216d8d898a4c10805963

Oracle validation
- MIN_CONFIDENCE=8000

Fees
- PROTOCOL_FEE_BPS=200
- LP_FEE_SHARE_BPS=2000
- CREATOR_FEE_SHARE_BPS=2000

SettlementRouter controls
- USE_RECEIVER_ALLOWLIST=true
- APPROVE_MARKET_REGISTRY_RECEIVER=true

---

## Post-deploy wiring (relayer)

Set in apps/relayer/.env

- CHANNEL_SETTLEMENT_ADDRESS=0xa1F7673D2677FB9e48C7a6295DD7cF44F8c0A212
- OPERATOR_PRIVATE_KEY=<private key for OPERATOR 0x38A8AB6EE17EB531d86eb877e56005587bC078e7>

---

## Verification (Foundry → Snowscan)

Snowscan Fuji verification is available through a Routescan-hosted Etherscan-compatible API. Foundry verification works using a verifier URL and any placeholder api key string.

Verifier URL (Fuji)
- https://api.routescan.io/v2/network/testnet/evm/43113/etherscan

API key
- ETHERSCAN_API_KEY=verifyContract

Verify all contracts (recommended)

```bash
source .env.fuji
chmod +x scripts/verify_fuji_snowtrace_stable.sh
RETRIES=10 SLEEP=12 WATCH=1 scripts/verify_fuji_snowtrace_stable.sh
