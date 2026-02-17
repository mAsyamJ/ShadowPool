// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console2} from "forge-std/Script.sol";

import {PoolMarketLegacy} from "../src/core/PoolMarketLegacy.sol";
import {ReportValidator} from "../src/oracle/ReportValidator.sol";
import {CREReceiver} from "../src/oracle/CREReceiver.sol";
import {OracleCoordinator} from "../src/oracle/OracleCoordinator.sol";
import {SettlementRouter} from "../src/core/SettlementRouter.sol";
import {MarketFactory} from "../src/core/MarketFactory.sol";

/// @title DeployDemo
/// @notice Deploys the minimal PoolMarketLegacy demo stack for full onchain trading.
/// @dev No ExecutionLedger, ChannelSettlement, or curated lane. For relayer + CRE use DeployTestnet.
contract DeployDemo is Script {
    struct Deployed {
        PoolMarketLegacy poolMarketLegacy;
        ReportValidator reportValidator;
        CREReceiver creReceiver;
        OracleCoordinator oracleCoordinator;
        SettlementRouter settlementRouter;
        MarketFactory marketFactory;
    }

    function run() external returns (Deployed memory d) {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address forwarder = vm.envAddress("CHAINLINK_FORWARDER");
        address settlementToken = vm.envAddress("SETTLEMENT_TOKEN");

        uint16 minConfidence = uint16(vm.envOr("MIN_CONFIDENCE", uint256(0)));
        bool useReceiverAllowlist = vm.envOr("USE_RECEIVER_ALLOWLIST", true);

        address expectedAuthor = vm.envOr("EXPECTED_WORKFLOW_AUTHOR", address(0));
        bytes32 expectedWorkflowId = vm.envOr("EXPECTED_WORKFLOW_ID", bytes32(0));
        string memory expectedWorkflowName = vm.envOr("EXPECTED_WORKFLOW_NAME", string(""));

        vm.startBroadcast(pk);

        d.poolMarketLegacy = new PoolMarketLegacy(forwarder, settlementToken);
        d.reportValidator = new ReportValidator(minConfidence);
        d.oracleCoordinator = new OracleCoordinator();
        d.settlementRouter = new SettlementRouter();
        d.creReceiver = new CREReceiver(forwarder, address(d.oracleCoordinator));
        d.marketFactory = new MarketFactory(forwarder, address(d.poolMarketLegacy));

        d.oracleCoordinator.setCreReceiver(address(d.creReceiver));
        d.oracleCoordinator.setSettlementRouter(address(d.settlementRouter));
        d.oracleCoordinator.setReportValidator(address(d.reportValidator));

        d.settlementRouter.setOracleCoordinator(address(d.oracleCoordinator));
        d.settlementRouter.setUseReceiverAllowlist(useReceiverAllowlist);
        d.settlementRouter.setMarketReceiverApproved(address(d.poolMarketLegacy), true);

        d.poolMarketLegacy.setMarketFactory(address(d.marketFactory));

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
            (bool okWorkflowId, ) =
                receiver.call(abi.encodeWithSignature("setExpectedWorkflowId(bytes32)", expectedWorkflowId));
            require(okWorkflowId, "setExpectedWorkflowId failed");
        }
        if (bytes(expectedWorkflowName).length != 0) {
            (bool okWorkflowName, ) =
                receiver.call(abi.encodeWithSignature("setExpectedWorkflowName(string)", expectedWorkflowName));
            require(okWorkflowName, "setExpectedWorkflowName failed");
        }
    }

    function _log(Deployed memory d) internal view {
        console2.log("deployer", msg.sender);
        console2.log("PoolMarketLegacy", address(d.poolMarketLegacy));
        console2.log("ReportValidator", address(d.reportValidator));
        console2.log("CREReceiver", address(d.creReceiver));
        console2.log("OracleCoordinator", address(d.oracleCoordinator));
        console2.log("SettlementRouter", address(d.settlementRouter));
        console2.log("MarketFactory", address(d.marketFactory));
        console2.log("");
        console2.log("Demo: direct predict/reducePosition/claim on PoolMarketLegacy.");
        console2.log("No relayer or ChannelSettlement. For production use DeployTestnet.");
    }
}
