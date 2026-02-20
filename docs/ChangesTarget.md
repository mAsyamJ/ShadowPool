Yes — let’s move to a **testnet deployment script** (Foundry `forge script`) that:

1. deploys in the correct order
2. wires every address exactly as required for your curated + checkpoint lane
3. optionally enables the oracle ingress pipeline (Forwarder/ReceiverTemplate) without blocking local testing

Below is a **production-style deployment script skeleton** you can drop into:

`packages/contracts/script/DeployTestnet.s.sol`

It’s written to match your **wiring truth** section (14.2) and your **current architecture**.

---

## 0) Environment variables (recommended)

Create `.env` (or export in shell):

```bash
export RPC_URL="https://sepolia.base.org"     # example
export PRIVATE_KEY="0x..."                    # deployer key
export OPERATOR="0x..."                       # checkpoint operator signer
export SETTLEMENT_TOKEN="0x..."               # ERC20 collateral asset (testnet USDC/mock)
export CHAINLINK_FORWARDER="0x..."            # Chainlink Forwarder for ReceiverTemplate
```

Optional (only if your ReceiverTemplate checks these):

```bash
export WORKFLOW_ID="0x..."                    # bytes32
export WORKFLOW_OWNER="0x..."                 # address
export WORKFLOW_NAME="RetroPickCRE"           # string (if used)
```

---

## 1) Deployment order (this matters)

**Core settlement lane must be wired in this order:**

1. ExecutionLedger
2. ChannelSettlement (needs vault/ledger/operator; plus setters after)
3. Vaults: MultiAssetVault (and/or CollateralVault)
4. MarketRegistry (needs vault/ledger)
5. Fee stack: FeeManager, FeePool, TreasuryPool
6. Oracle: ReportValidator, CREReceiver, OracleCoordinator, SettlementRouter
7. Curation: MarketPolicy, MarketDraftBoard, LiquidityVaultFactory, DraftClaimManager, CREPublishReceiver, MarketFactory
8. Post-wiring: set all addresses + roles + allowlists

---

## 2) Foundry deployment script (Solidity)

> This script assumes your contracts expose the setters described in your docs. If a setter name differs in your repo, just rename the call — the wiring graph is correct.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

// ====== core / execution ======
import {ExecutionLedger} from "../src/execution/ExecutionLedger.sol";
import {ChannelSettlement} from "../src/execution/ChannelSettlement.sol";
import {MarketRegistry} from "../src/core/MarketRegistry.sol";
import {MultiAssetVault} from "../src/execution/MultiAssetVault.sol";
import {CollateralVault} from "../src/execution/CollateralVault.sol";
import {CollateralVaultAdapter} from "../src/execution/CollateralVaultAdapter.sol";

// ====== fees ======
import {FeeManager} from "../src/fees/FeeManager.sol";
import {FeePool} from "../src/fees/FeePool.sol";
import {TreasuryPool} from "../src/fees/TreasuryPool.sol";

// ====== oracle ======
import {ReportValidator} from "../src/oracle/ReportValidator.sol";
import {CREReceiver} from "../src/oracle/CREReceiver.sol";
import {OracleCoordinator} from "../src/oracle/OracleCoordinator.sol";
import {SettlementRouter} from "../src/core/SettlementRouter.sol";

// ====== curation ======
import {MarketPolicy} from "../src/curation/MarketPolicy.sol";
import {MarketDraftBoard} from "../src/curation/MarketDraftBoard.sol";
import {DraftClaimManager} from "../src/curation/DraftClaimManager.sol";
import {LiquidityVaultFactory} from "../src/curation/LiquidityVaultFactory.sol";
import {CREPublishReceiver} from "../src/curation/CREPublishReceiver.sol";
import {MarketFactory} from "../src/core/MarketFactory.sol";

contract DeployTestnet is Script {
    struct Deployed {
        // execution lane
        ExecutionLedger ledger;
        ChannelSettlement channelSettlement;
        MultiAssetVault mav;
        CollateralVault cv;
        CollateralVaultAdapter cvAdapter;
        MarketRegistry registry;

        // fees
        FeeManager feeManager;
        FeePool feePool;
        TreasuryPool treasuryPool;

        // oracle
        ReportValidator reportValidator;
        CREReceiver creReceiver;
        OracleCoordinator oracleCoordinator;
        SettlementRouter settlementRouter;

        // curation
        MarketPolicy marketPolicy;
        MarketDraftBoard draftBoard;
        LiquidityVaultFactory liquidityVaultFactory;
        DraftClaimManager draftClaimManager;
        CREPublishReceiver crePublishReceiver;
        MarketFactory marketFactory;
    }

    function run() external returns (Deployed memory d) {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address operator = vm.envAddress("OPERATOR");

        address settlementToken = vm.envAddress("SETTLEMENT_TOKEN");
        address forwarder = vm.envAddress("CHAINLINK_FORWARDER");

        vm.startBroadcast(pk);

        // ============================================================
        // 1) Execution settlement lane
        // ============================================================

        d.ledger = new ExecutionLedger();

        // If your ChannelSettlement constructor differs, adjust params here.
        // Older version: (vault, ledger, operator). Your current build likely also uses setters for registry/fees.
        // We'll deploy vault(s) first only if constructor needs vault; otherwise deploy CS now then set vaults later.
        // Here: deploy ChannelSettlement now with placeholder vault address(0) only if supported; otherwise reorder.

        // --- Choose ONE custody model for testnet ---
        // Recommended: MultiAssetVault (even if single asset) for future-proofing.
        d.mav = new MultiAssetVault(address(0)); // channelSettlement set after CS deployment (constructor expects CS)
        // For compatibility (optional), deploy CollateralVault + adapter:
        d.cv = new CollateralVault(settlementToken, address(0)); // channelSettlement set after CS
        d.cvAdapter = new CollateralVaultAdapter(address(d.cv)); // if your adapter requires only CV

        // Now deploy ChannelSettlement with real vault + ledger + operator
        // If your CS expects IMultiAssetVault or address vault, pick MAV for execution lane.
        // If CS has separate setters for MAV/CV, deploy with dummy and set later.
        d.channelSettlement = new ChannelSettlement(
            address(d.mav),       // or address(d.cv) depending on your CS interface
            address(d.ledger),
            operator
        );

        // wire vaults -> settlement + registry (registry deployed later)
        d.mav.setChannelSettlement(address(d.channelSettlement));
        d.cv.setChannelSettlement(address(d.channelSettlement));

        // Set ledger channelSettlement (if your ledger has a setter)
        // d.ledger.setChannelSettlement(address(d.channelSettlement));

        // Deploy MarketRegistry (needs vault + ledger)
        // If your registry expects IMultiAssetVault-like or separate fields, use MAV and keep CV as fallback.
        d.registry = new MarketRegistry(address(d.mav), address(d.ledger));

        // Complete vault wiring for redeem:
        d.mav.setMarketRegistry(address(d.registry));
        d.cv.setMarketRegistry(address(d.registry));

        // Complete CS wiring to registry (if your CS has setter)
        // d.channelSettlement.setMarketRegistry(address(d.registry));

        // ============================================================
        // 2) Fee stack
        // ============================================================

        d.feeManager = new FeeManager(100); // 1% example; change as needed
        d.feePool = new FeePool();
        d.treasuryPool = new TreasuryPool();

        // FeePool wiring (collector = ChannelSettlement)
        d.feePool.setFeeCollector(address(d.channelSettlement));
        d.feePool.setTreasury(address(d.treasuryPool));

        // ChannelSettlement wiring to fee stack
        // d.channelSettlement.setFeeManager(address(d.feeManager));
        // d.channelSettlement.setFeePool(address(d.feePool));
        // d.channelSettlement.setTreasuryPool(address(d.treasuryPool));

        // ============================================================
        // 3) Oracle ingress + routing
        // ============================================================

        d.reportValidator = new ReportValidator();
        // d.reportValidator.setMinConfidence(...);

        d.creReceiver = new CREReceiver(forwarder /* plus any ctor args your ReceiverTemplate needs */);

        d.oracleCoordinator = new OracleCoordinator();
        d.settlementRouter = new SettlementRouter();

        // OracleCoordinator wiring
        d.oracleCoordinator.setCREReceiver(address(d.creReceiver));
        d.oracleCoordinator.setSettlementRouter(address(d.settlementRouter));
        d.oracleCoordinator.setReportValidator(address(d.reportValidator));

        // SettlementRouter wiring
        d.settlementRouter.setOracleCoordinator(address(d.oracleCoordinator));
        d.settlementRouter.setChannelSettlement(address(d.channelSettlement));
        // optional fallback
        // d.settlementRouter.setSessionFinalizer(address(...));

        // MarketRegistry must accept only router for resolve
        d.registry.setSettlementRouter(address(d.settlementRouter));

        // ============================================================
        // 4) Curated pipeline (Draft -> ClaimAndSeed -> Publish)
        // ============================================================

        d.marketPolicy = new MarketPolicy();
        d.draftBoard = new MarketDraftBoard();
        d.liquidityVaultFactory = new LiquidityVaultFactory();
        d.draftClaimManager = new DraftClaimManager();
        d.crePublishReceiver = new CREPublishReceiver(forwarder /* + args */);
        d.marketFactory = new MarketFactory();

        // DraftBoard wiring
        d.draftBoard.setDraftClaimManager(address(d.draftClaimManager));
        // grant publish role to MarketFactory (if role-based)
        d.draftBoard.grantPublishCallerRole(address(d.marketFactory));

        // Liquidity vault factory must know ChannelSettlement for vault hook security
        d.liquidityVaultFactory.setChannelSettlement(address(d.channelSettlement));

        // ClaimManager wiring
        d.draftClaimManager.setDraftBoard(address(d.draftBoard));
        d.draftClaimManager.setLiquidityVaultFactory(address(d.liquidityVaultFactory));

        // MarketFactory wiring
        d.marketFactory.setMarketRegistry(address(d.registry));
        d.marketFactory.setDraftBoard(address(d.draftBoard));
        d.marketFactory.setDraftClaimManager(address(d.draftClaimManager));
        d.marketFactory.setPolicy(address(d.marketPolicy));
        d.marketFactory.setSettlementTargetLegacy(address(0)); // if you still support PoolMarketLegacy creation

        // Allow CREPublishReceiver to call createFromDraft
        d.marketFactory.setApprovedPublishReceiver(address(d.crePublishReceiver), true);

        // CREPublishReceiver wiring (policy, factory, claim manager, draft board)
        d.crePublishReceiver.setPolicy(address(d.marketPolicy));
        d.crePublishReceiver.setDraftBoard(address(d.draftBoard));
        d.crePublishReceiver.setDraftClaimManager(address(d.draftClaimManager));
        d.crePublishReceiver.setMarketFactory(address(d.marketFactory));

        // Registry must accept factory for createFor + setLiquidityVault
        d.registry.setMarketFactory(address(d.marketFactory));

        vm.stopBroadcast();

        // Optionally: write addresses to JSON (nice for frontend / relayer)
        _writeAddresses(d);

        return d;
    }

    function _writeAddresses(Deployed memory d) internal {
        // Minimal example: just emit logs
        console2.log("ExecutionLedger:", address(d.ledger));
        console2.log("ChannelSettlement:", address(d.channelSettlement));
        console2.log("MarketRegistry:", address(d.registry));
        console2.log("MultiAssetVault:", address(d.mav));
        console2.log("CollateralVault:", address(d.cv));
        console2.log("FeeManager:", address(d.feeManager));
        console2.log("FeePool:", address(d.feePool));
        console2.log("TreasuryPool:", address(d.treasuryPool));
        console2.log("CREReceiver:", address(d.creReceiver));
        console2.log("OracleCoordinator:", address(d.oracleCoordinator));
        console2.log("SettlementRouter:", address(d.settlementRouter));
        console2.log("DraftBoard:", address(d.draftBoard));
        console2.log("DraftClaimManager:", address(d.draftClaimManager));
        console2.log("LiquidityVaultFactory:", address(d.liquidityVaultFactory));
        console2.log("CREPublishReceiver:", address(d.crePublishReceiver));
        console2.log("MarketFactory:", address(d.marketFactory));
        console2.log("MarketPolicy:", address(d.marketPolicy));
    }
}
```

### Two important notes about the script

* **If your constructor signatures differ** (very likely for `CREReceiver`, `MarketFactory`, `MarketDraftBoard`, etc), keep the **same deployment order + wiring**, but adjust the exact calls.
* I intentionally used **MultiAssetVault as primary**, and deployed CollateralVault only as compatibility. For testnet, you can simplify and deploy only MAV.

---

## 3) Run it on testnet

From `packages/contracts`:

```bash
forge script script/DeployTestnet.s.sol:DeployTestnet \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify
```

If you don’t want verification yet:

```bash
forge script script/DeployTestnet.s.sol:DeployTestnet \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast
```

---

## 4) Post-deploy smoke checks (must do)

Run these calls (via cast) to ensure no silent miswire:

```bash
# Router->Coordinator
cast call $SETTLEMENT_ROUTER "oracleCoordinator()(address)" --rpc-url $RPC_URL

# Registry gates
cast call $MARKET_REGISTRY "settlementRouter()(address)" --rpc-url $RPC_URL
cast call $MARKET_REGISTRY "marketFactory()(address)" --rpc-url $RPC_URL

# Vault gates
cast call $MULTI_ASSET_VAULT "channelSettlement()(address)" --rpc-url $RPC_URL
cast call $MULTI_ASSET_VAULT "marketRegistry()(address)" --rpc-url $RPC_URL

# Fee collector gates
cast call $FEE_POOL "feeCollector()(address)" --rpc-url $RPC_URL

# Coordinator gates
cast call $ORACLE_COORDINATOR "creReceiver()(address)" --rpc-url $RPC_URL
cast call $ORACLE_COORDINATOR "settlementRouter()(address)" --rpc-url $RPC_URL
```

If any mismatch: fix immediately before running CRE.

---

## 5) Next step after deployment script (the real unlock)

After contracts are deployed, the **next practical step** is a “Create Draft → ClaimAndSeed → Publish” smoke test on-chain:

1. `MarketDraftBoard.proposeDraft(...)` (as AI_ORACLE_ROLE)
2. `DraftClaimManager.claimAndSeed(...)` with seed token approval
3. `CREPublishReceiver.onReport(0x04 || payload)` (simulate via `cast send` if you disable forwarder checks on testnet)
4. Verify:

   * market created in `MarketRegistry`
   * liquidity vault bound
   * redeem path works after mocked settlement

---

If you paste your **actual constructor signatures** for:

* `CREReceiver`
* `MarketDraftBoard`
* `MarketFactory`
* `CREPublishReceiver`
* `FeePool`
* `TreasuryPool`

…I can adjust the script to be **drop-in compiling** with zero edits.
