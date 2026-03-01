# RetroPick Frontend Deployment Config

**Last updated:** 2026-03-01  
**Audience:** Frontend engineers  
**Context:** [README.md](../../../README.md) | [Frontend.md](Frontend.md)

---

## 1. Network (Avalanche Fuji)

| Parameter | Value |
|-----------|-------|
| **Chain** | Avalanche Fuji (C-Chain) |
| **Chain ID** | 43113 |
| **Explorer** | [testnet.snowscan.xyz](https://testnet.snowscan.xyz) |
| **RPC** | `https://avalanche-fuji.infura.io/v3/YOUR_PROJECT_ID` or public RPC |

---

## 2. DeployBetaTestnet Addresses (Fuji — V3-Escrow)

These addresses are the **active deployment** for beta testers. Mock tokens + Faucet; use for frontend integration.

### 2.1 Core Contracts

| Contract | Address | ABI Path |
|----------|---------|----------|
| MarketRegistry | `0x3235094A8826a6205F0A0b74E2370A4AC39c6Cc2` | `docs/abi/MarketRegistry.json` |
| MarketDraftBoard | `0x8a81759d0A4383E4879b0Ff298Bf60ff24be8302` | `docs/abi/MarketDraftBoard.json` |
| DraftClaimManager | `0x0b7B98b10b2067a4918720Bc04f374c669B313d5` | `docs/abi/DraftClaimManager.json` |
| MarketFactory | `0x2f70602034854C14CBfD1F94C713f833d344d748` | `docs/abi/MarketFactory.json` |
| OutcomeToken1155 | `0x9B413811ecfD0e0679A7Ba785de44E15E7482044` | `docs/abi/OutcomeToken1155.json` |
| MarketRiskManager | `0x9DB5b69A6EdCC433e56C3C96e770A737a4b13555` | `docs/abi/MarketRiskManager.json` |
| ChannelSettlement | `0xFA5D0e64B0B21374690345d4A88a9748C7E22182` | `docs/abi/ChannelSettlement.json` |
| MultiAssetVault | `0x71EEA55f90c028aEE2b0F0785d015ea4e9165aBF` | `docs/abi/MultiAssetVault.json` |
| CollateralVault | `0x792a065dD308A1Fc3d115Ea006b3093D8fBd7ea1` | `docs/abi/CollateralVault.json` |
| LiquidityVaultFactory | `0x714518B11a4ce31C4fE42F0155473FD5158AD84e` | `docs/abi/LiquidityVaultFactory.json` |
| CREPublishReceiver | `0x3AA7E5A28A72Df248806397Ea16C03fB10c46830` | `docs/abi/CREPublishReceiver.json` |

### 2.2 Fee Contracts

| Contract | Address | ABI Path |
|----------|---------|----------|
| FeeManager | `0x40094a387A609b5B983CD7eC8Ce3Ac44Ccbca1Db` | `docs/abi/FeeManager.json` |
| FeePool | `0xB0d262089Cd5F66239298eb462D878fC50CBD2f3` | `docs/abi/FeePool.json` |
| TreasuryPool | `0x504313Da50e3E3d42769B96A16B9F58C2B84348a` | `docs/abi/TreasuryPool.json` |

### 2.3 Oracle / Routing (Read-Only for Frontend)

| Contract | Address | ABI Path |
|----------|---------|----------|
| CREReceiver | `0x51c0680d8E9fFE2A2f6CC65e598280D617D6cAb7` | `docs/abi/CREReceiver.json` |
| OracleCoordinator | `0x101053889dE4748763AA337685aA6842D3D4723C` | `docs/abi/OracleCoordinator.json` |
| SettlementRouter | `0xBfE28C2740C4b9Ee87299EF0a6590b21C0EBa4d0` | `docs/abi/SettlementRouter.json` |
| ReportValidator | `0x45Ac2A2473675D7baA7b24E07dc9A4053b005282` | `docs/abi/ReportValidator.json` |

### 2.4 Mock Tokens (Settlement / Faucet)

| Token | Address | Use |
|-------|---------|-----|
| MockUSDC (settlement) | `0x61c8d94ab8a729126a9FA41751FaD7F464604948` | Primary settlement; MultiAssetVault default |
| MockDAI | `0xfefF1c0df050cDcD7dD6988749654A3a8948d746` | Faucet |
| MockUSDT | `0xEcED85042Cbbb7756E0809e51aDf7B7a8d2851Aa` | Faucet |
| MockEURC | `0x08f7a4CFba8E8c944D33630faA2032b3B3b7c5e1` | Faucet |
| MockAVAX | `0x8CA51cb13B91A6530429f154B8505c40BE0d7908` | Faucet |
| MockIDRX | `0x952877CD34812E316CfE2324A632ad5c71d096EA` | Faucet |

### 2.5 Faucet (Testnet Only)

| Contract | Address | ABI Path |
|----------|---------|----------|
| Faucet | `0x4d74eCEc809D1DbbD8D4B9D1c26fFc8b8FbA9E89` | `docs/abi/Faucet.json` |

### 2.6 Policy

| Contract | Address | ABI Path |
|----------|---------|----------|
| MarketPolicy | `0x041584444a592d9c9Dbd7D1EDc110D63643408b5` | `docs/abi/MarketPolicy.json` |

---

## 3. Relayer Config

| Variable | Value | Use |
|----------|-------|-----|
| `CHANNEL_SETTLEMENT_ADDRESS` | `0xFA5D0e64B0B21374690345d4A88a9748C7E22182` | EIP-712 `verifyingContract` for checkpoint signing |
| Relayer base URL | e.g. `http://localhost:8790` | `GET/POST /cre/checkpoints/:sessionId` |

---

## 4. CRE (Reference Only)

Frontend does **not** configure CRE. For understanding:

- **Chainlink Forwarder:** Reports delivered via Forwarder; CRE workflows call `writeReport`.
- **Outcome resolution, publish, checkpoint delivery:** Backend/CRE-driven.

---

## 5. Environment Template (Frontend)

```bash
# Network
NEXT_PUBLIC_CHAIN_ID=43113
NEXT_PUBLIC_RPC_URL=https://avalanche-fuji.infura.io/v3/YOUR_PROJECT_ID
NEXT_PUBLIC_EXPLORER_URL=https://testnet.snowscan.xyz

# Core contracts (DeployBetaTestnet)
NEXT_PUBLIC_MARKET_REGISTRY=0x3235094A8826a6205F0A0b74E2370A4AC39c6Cc2
NEXT_PUBLIC_MARKET_DRAFT_BOARD=0x8a81759d0A4383E4879b0Ff298Bf60ff24be8302
NEXT_PUBLIC_DRAFT_CLAIM_MANAGER=0x0b7B98b10b2067a4918720Bc04f374c669B313d5
NEXT_PUBLIC_OUTCOME_TOKEN=0x9B413811ecfD0e0679A7Ba785de44E15E7482044
NEXT_PUBLIC_CHANNEL_SETTLEMENT=0xFA5D0e64B0B21374690345d4A88a9748C7E22182
NEXT_PUBLIC_MULTI_ASSET_VAULT=0x71EEA55f90c028aEE2b0F0785d015ea4e9165aBF
NEXT_PUBLIC_COLLATERAL_VAULT=0x792a065dD308A1Fc3d115Ea006b3093D8fBd7ea1
NEXT_PUBLIC_FAUCET=0x4d74eCEc809D1DbbD8D4B9D1c26fFc8b8FbA9E89
NEXT_PUBLIC_MOCK_USDC=0x61c8d94ab8a729126a9FA41751FaD7F464604948

# Relayer
NEXT_PUBLIC_RELAYER_URL=http://localhost:8790
```

---

## 6. References

- [README.md](../../../README.md) — Full deployment table, legacy DeployTestnet
- [Frontend.md](Frontend.md) — Contract-to-feature mapping
- [SystemIntegration.md](SystemIntegration.md) — Architecture overview
