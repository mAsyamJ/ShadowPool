// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @title DeployTestnet
/// @notice Deploys the CRE + Nitrolite Yellow checkpoint production stack.
/// @dev Uses MarketRegistry + ChannelSettlement. Does NOT deploy PoolMarketLegacy or SessionFinalizer.
///      For relayer: set CHANNEL_SETTLEMENT_ADDRESS and OPERATOR_PRIVATE_KEY in apps/relayer/.env.

import {Script, console2} from "forge-std/Script.sol";

import {ExecutionLedger} from "../src/execution/ExecutionLedger.sol";
import {ChannelSettlement} from "../src/execution/ChannelSettlement.sol";
import {MultiAssetVault} from "../src/execution/MultiAssetVault.sol";
import {CollateralVault} from "../src/execution/CollateralVault.sol";
import {MarketRegistry} from "../src/core/MarketRegistry.sol";

import {FeeManager} from "../src/fees/FeeManager.sol";
import {FeePool} from "../src/fees/FeePool.sol";
import {TreasuryPool} from "../src/fees/TreasuryPool.sol";

import {ReportValidator} from "../src/oracle/ReportValidator.sol";
import {CREReceiver} from "../src/oracle/CREReceiver.sol";
import {OracleCoordinator} from "../src/oracle/OracleCoordinator.sol";
import {SettlementRouter} from "../src/core/SettlementRouter.sol";

import {MarketPolicy} from "../src/curation/MarketPolicy.sol";
import {MarketDraftBoard} from "../src/curation/MarketDraftBoard.sol";
import {DraftClaimManager} from "../src/curation/DraftClaimManager.sol";
import {LiquidityVaultFactory} from "../src/curation/LiquidityVaultFactory.sol";
import {CREPublishReceiver} from "../src/curation/CREPublishReceiver.sol";
import {MarketFactory} from "../src/core/MarketFactory.sol";

contract DeployTestnet is Script {
    struct Deployed {
        ExecutionLedger ledger;
        ChannelSettlement channelSettlement;
        MultiAssetVault multiAssetVault;
        CollateralVault collateralVault;
        MarketRegistry marketRegistry;
        FeeManager feeManager;
        FeePool feePool;
        TreasuryPool treasuryPool;
        ReportValidator reportValidator;
        CREReceiver creReceiver;
        OracleCoordinator oracleCoordinator;
        SettlementRouter settlementRouter;
        MarketPolicy marketPolicy;
        MarketDraftBoard draftBoard;
        DraftClaimManager draftClaimManager;
        LiquidityVaultFactory liquidityVaultFactory;
        CREPublishReceiver crePublishReceiver;
        MarketFactory marketFactory;
    }

    function run() external returns (Deployed memory d) {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address operator = vm.envAddress("OPERATOR");
        address settlementToken = vm.envAddress("SETTLEMENT_TOKEN");
        address forwarder = vm.envAddress("CHAINLINK_FORWARDER");

        uint16 minConfidence = uint16(vm.envUint("MIN_CONFIDENCE"));
        uint16 protocolFeeBps = uint16(vm.envUint("PROTOCOL_FEE_BPS"));
        uint16 lpFeeShareBps = uint16(vm.envUint("LP_FEE_SHARE_BPS"));
        uint16 creatorFeeShareBps = uint16(vm.envUint("CREATOR_FEE_SHARE_BPS"));
        bool useReceiverAllowlist = vm.envBool("USE_RECEIVER_ALLOWLIST");
        bool approveRegistryReceiver = vm.envBool("APPROVE_MARKET_REGISTRY_RECEIVER");

        address expectedAuthor = vm.envOr("EXPECTED_WORKFLOW_AUTHOR", address(0));
        bytes32 expectedWorkflowId = vm.envOr("EXPECTED_WORKFLOW_ID", bytes32(0));
        string memory expectedWorkflowName = vm.envOr("EXPECTED_WORKFLOW_NAME", string(""));

        vm.startBroadcast(pk);

        // 1) Execution lane
        d.ledger = new ExecutionLedger(address(0));
        d.multiAssetVault = new MultiAssetVault(address(0));
        d.collateralVault = new CollateralVault(settlementToken, address(0));
        d.channelSettlement = new ChannelSettlement(address(d.collateralVault), address(d.ledger), operator);
        d.marketRegistry = new MarketRegistry(address(d.collateralVault), address(d.ledger));

        d.ledger.setChannelSettlement(address(d.channelSettlement));
        d.multiAssetVault.setChannelSettlement(address(d.channelSettlement));
        d.multiAssetVault.setMarketRegistry(address(d.marketRegistry));
        d.collateralVault.setChannelSettlement(address(d.channelSettlement));
        d.collateralVault.setMarketRegistry(address(d.marketRegistry));
        d.channelSettlement.setMarketRegistry(address(d.marketRegistry));
        d.channelSettlement.setMultiAssetVault(address(d.multiAssetVault));
        d.marketRegistry.setMultiAssetVault(address(d.multiAssetVault));
        d.marketRegistry.setDefaultSettlementAsset(settlementToken);

        // 2) Fees
        d.feeManager = new FeeManager(protocolFeeBps);
        d.feePool = new FeePool();
        d.treasuryPool = new TreasuryPool();

        d.feeManager.setLpFeeShareBps(lpFeeShareBps);
        d.feeManager.setCreatorFeeShareBps(creatorFeeShareBps);
        d.feePool.setFeeCollector(address(d.channelSettlement));
        d.feePool.setTreasuryPool(address(d.treasuryPool));
        d.channelSettlement.setFeeManager(address(d.feeManager));
        d.channelSettlement.setFeePool(address(d.feePool));

        // 3) Oracle and routing
        d.reportValidator = new ReportValidator(minConfidence);
        d.oracleCoordinator = new OracleCoordinator();
        d.settlementRouter = new SettlementRouter();
        d.creReceiver = new CREReceiver(forwarder, address(d.oracleCoordinator));

        d.oracleCoordinator.setCreReceiver(address(d.creReceiver));
        d.oracleCoordinator.setSettlementRouter(address(d.settlementRouter));
        d.oracleCoordinator.setReportValidator(address(d.reportValidator));

        d.settlementRouter.setOracleCoordinator(address(d.oracleCoordinator));
        d.settlementRouter.setChannelSettlement(address(d.channelSettlement));
        d.settlementRouter.setUseReceiverAllowlist(useReceiverAllowlist);
        if (approveRegistryReceiver) {
            d.settlementRouter.setMarketReceiverApproved(address(d.marketRegistry), true);
        }

        d.marketRegistry.setSettlementRouter(address(d.settlementRouter));

        // 4) Curated lane
        d.marketPolicy = new MarketPolicy();
        d.draftBoard = new MarketDraftBoard();
        d.draftClaimManager = new DraftClaimManager(address(d.draftBoard));
        d.liquidityVaultFactory = new LiquidityVaultFactory(address(d.channelSettlement));
        d.marketFactory = new MarketFactory(forwarder, address(d.marketRegistry));
        d.crePublishReceiver = new CREPublishReceiver(
            forwarder,
            address(d.draftBoard),
            address(d.draftClaimManager),
            address(d.marketPolicy),
            address(d.marketFactory)
        );

        d.draftBoard.setDraftClaimManager(address(d.draftClaimManager));
        d.draftBoard.grantPublishCaller(address(d.marketFactory));
        address aiOracle = vm.envOr("AI_ORACLE_ADDRESS", address(0));
        if (aiOracle != address(0)) {
            d.draftBoard.grantRole(d.draftBoard.AI_ORACLE_ROLE(), aiOracle);
        }
        d.draftClaimManager.setLiquidityVaultFactory(address(d.liquidityVaultFactory));

        d.marketFactory.setMarketRegistry(address(d.marketRegistry));
        d.marketFactory.setDraftBoard(address(d.draftBoard));
        d.marketFactory.setDraftClaimManager(address(d.draftClaimManager));
        d.marketFactory.setPublishReceiverApproved(address(d.crePublishReceiver), true);

        d.marketRegistry.setMarketFactory(address(d.marketFactory));

        _configureReceiverTemplate(address(d.creReceiver), expectedAuthor, expectedWorkflowId, expectedWorkflowName);
        _configureReceiverTemplate(address(d.crePublishReceiver), expectedAuthor, expectedWorkflowId, expectedWorkflowName);
        _configureReceiverTemplate(address(d.marketFactory), expectedAuthor, expectedWorkflowId, expectedWorkflowName);

        vm.stopBroadcast();

        _log(d);
        return d;
    }

    function _configureReceiverTemplate(
        address receiver,
        address expectedAuthor,
        bytes32 expectedWorkflowId,
        string memory expectedWorkflowName
    ) internal {
        if (expectedAuthor != address(0)) {
            (bool okAuthor, ) = receiver.call(abi.encodeWithSignature("setExpectedAuthor(address)", expectedAuthor));
            require(okAuthor, "setExpectedAuthor failed");
        }
        if (expectedWorkflowId != bytes32(0)) {
            (bool okWorkflowId, ) = receiver.call(abi.encodeWithSignature("setExpectedWorkflowId(bytes32)", expectedWorkflowId));
            require(okWorkflowId, "setExpectedWorkflowId failed");
        }
        if (bytes(expectedWorkflowName).length != 0) {
            (bool okWorkflowName, ) =
                receiver.call(abi.encodeWithSignature("setExpectedWorkflowName(string)", expectedWorkflowName));
            require(okWorkflowName, "setExpectedWorkflowName failed");
        }
    }

    /// @notice After deployment, set CHANNEL_SETTLEMENT_ADDRESS in apps/relayer/.env for checkpoint payload building
    function _log(Deployed memory d) internal view {
        console2.log("deployer", msg.sender);
        console2.log("ExecutionLedger", address(d.ledger));
        console2.log("ChannelSettlement", address(d.channelSettlement));
        console2.log("MultiAssetVault", address(d.multiAssetVault));
        console2.log("CollateralVault", address(d.collateralVault));
        console2.log("MarketRegistry", address(d.marketRegistry));
        console2.log("FeeManager", address(d.feeManager));
        console2.log("FeePool", address(d.feePool));
        console2.log("TreasuryPool", address(d.treasuryPool));
        console2.log("ReportValidator", address(d.reportValidator));
        console2.log("CREReceiver", address(d.creReceiver));
        console2.log("OracleCoordinator", address(d.oracleCoordinator));
        console2.log("SettlementRouter", address(d.settlementRouter));
        console2.log("MarketPolicy", address(d.marketPolicy));
        console2.log("MarketDraftBoard", address(d.draftBoard));
        console2.log("DraftClaimManager", address(d.draftClaimManager));
        console2.log("LiquidityVaultFactory", address(d.liquidityVaultFactory));
        console2.log("MarketFactory", address(d.marketFactory));
        console2.log("CREPublishReceiver", address(d.crePublishReceiver));
        console2.log("");
        console2.log("--- Post-deploy checklist ---");
        console2.log("");
        console2.log("1. Relayer (apps/relayer/.env):");
        console2.log("   CHANNEL_SETTLEMENT_ADDRESS=%s", address(d.channelSettlement));
        console2.log("   OPERATOR_PRIVATE_KEY=<same operator key as OPERATOR env>");
        console2.log("");
        console2.log("2. CRE workflows: configure receivers:");
        console2.log("   CREReceiver (outcome resolution + checkpoint submit): %s", address(d.creReceiver));
        console2.log("   CREPublishReceiver (publish from draft): %s", address(d.crePublishReceiver));
        console2.log("   MarketFactory (CRE feed market creation): %s", address(d.marketFactory));
        console2.log("");
        console2.log("3. Draft proposals: deployer has AI_ORACLE_ROLE. Set AI_ORACLE_ADDRESS to grant to CRE workflow.");
    }
}
