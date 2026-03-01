
#### Legacy: DeployTestnet (earlier deployment)

Script: `DeployTestnet.s.sol` — Real Fuji USDC, ExecutionLedger. Different addresses from above.

| Contract              | Address |
| --------------------- | ------- |
| ExecutionLedger       | [0xE4d4187d6Ca2c4eA36A05d3eb61a7A79da7F6D25](https://testnet.snowtrace.io/address/0xE4d4187d6Ca2c4eA36A05d3eb61a7A79da7F6D25/contract/43113/code?chainid=43113) |
| ChannelSettlement     | [0xa1F7673D2677FB9e48C7a6295DD7cF44F8c0A212](https://testnet.snowtrace.io/address/0xa1F7673D2677FB9e48C7a6295DD7cF44F8c0A212/contract/43113/code?chainid=43113) |
| CREReceiver           | [0xf427BC9e8C7004F394fa06147bf42aad1D516FdF](https://testnet.snowtrace.io/address/0xf427BC9e8C7004F394fa06147bf42aad1D516FdF/contract/43113/code?chainid=43113) |
| MarketRegistry        | [0xdB8d890B9aE6A40D2838A508F7D2126cb42a36E4](https://testnet.snowtrace.io/address/0xdB8d890B9aE6A40D2838A508F7D2126cb42a36E4/contract/43113/code?chainid=43113) |
| MarketFactory         | [0x68D0e961FdFAF031323099a4680847321eFBb7e5](https://testnet.snowtrace.io/address/0x68D0e961FdFAF031323099a4680847321eFBb7e5/contract/43113/code?chainid=43113) |
| MultiAssetVault       | [0xf780caB68DE9800fd6b8ee6AEfc0b06A5F3181dB](https://testnet.snowtrace.io/address/0xf780caB68DE9800fd6b8ee6AEfc0b06A5F3181dB/contract/43113/code?chainid=43113) |
| CollateralVault       | [0xe1557c8f239752A22278a5c55f0CB28b041D9fcd](https://testnet.snowtrace.io/address/0xe1557c8f239752A22278a5c55f0CB28b041D9fcd/contract/43113/code?chainid=43113) |
| SettlementRouter      | [0x789daEE98ac0C8EEe220Dd768f0e2A05C66B983E](https://testnet.snowtrace.io/address/0x789daEE98ac0C8EEe220Dd768f0e2A05C66B983E/contract/43113/code?chainid=43113) |
| FeeManager            | [0xB9C04B35C64dc263809DaeA3233de0855b44a82D](https://testnet.snowtrace.io/address/0xB9C04B35C64dc263809DaeA3233de0855b44a82D/contract/43113/code?chainid=43113) |
| FeePool               | [0x59d2B7563bC7b80c3EcE9A3E616441e68ca158A6](https://testnet.snowtrace.io/address/0x59d2B7563bC7b80c3EcE9A3E616441e68ca158A6/contract/43113/code?chainid=43113) |
| TreasuryPool          | [0x1723701b8143537e023b9C6165dAeF9A67125d43](https://testnet.snowtrace.io/address/0x1723701b8143537e023b9C6165dAeF9A67125d43/contract/43113/code?chainid=43113) |
| ReportValidator       | [0xC6c31b73CE71B42aB45dd017061fcd5D9620a1bE](https://testnet.snowtrace.io/address/0xC6c31b73CE71B42aB45dd017061fcd5D9620a1bE/contract/43113/code?chainid=43113) |
| OracleCoordinator     | [0xA30Fa013c5CAe93C2e75129ceA669635e011d6F8](https://testnet.snowtrace.io/address/0xA30Fa013c5CAe93C2e75129ceA669635e011d6F8/contract/43113/code?chainid=43113) |
| MarketPolicy          | [0x98f399081CbDB2eeB66c8c3c51F5fF592A045396](https://testnet.snowtrace.io/address/0x98f399081CbDB2eeB66c8c3c51F5fF592A045396/contract/43113/code?chainid=43113) |
| MarketDraftBoard      | [0xa1A31B61748252D7E1f15B2F74de0ce99f1a296f](https://testnet.snowtrace.io/address/0xa1A31B61748252D7E1f15B2F74de0ce99f1a296f/contract/43113/code?chainid=43113) |
| DraftClaimManager     | [0x1Ccccc54e0cE928b3FC04aA2Ed4E012E7EaAdDe9](https://testnet.snowtrace.io/address/0x1Ccccc54e0cE928b3FC04aA2Ed4E012E7EaAdDe9/contract/43113/code?chainid=43113) |
| LiquidityVaultFactory | [0xd895dD8547A0fC6214A7ce9D74B49F9b0601C362](https://testnet.snowtrace.io/address/0xd895dD8547A0fC6214A7ce9D74B49F9b0601C362/contract/43113/code?chainid=43113) |
| CREPublishReceiver    | [0xEF0aebe656c82A6d070f904c0c31EE1B0B81fBB2](https://testnet.snowtrace.io/address/0xEF0aebe656c82A6d070f904c0c31EE1B0B81fBB2/contract/43113/code?chainid=43113) |

### Deployment Parameters (Fuji)

| Parameter | Value |
|-----------|-------|
| SETTLEMENT_TOKEN (USDC) | `0x5425890298aed601595a70AB815c96711a31Bc65` |
| CHAINLINK_FORWARDER | `0x2e7371a5d032489e4f60216d8d898a4c10805963` |
| MIN_CONFIDENCE | 8000 (80%) |
| PROTOCOL_FEE_BPS | 200 (2%) |
| LP_FEE_SHARE_BPS | 2000 (20%) |
| CREATOR_FEE_SHARE_BPS | 2000 (20%) |
