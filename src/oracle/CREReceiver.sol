// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ReceiverTemplate} from "../interfaces/ReceiverTemplate.sol";
import {OracleCoordinator} from "./OracleCoordinator.sol";

/// @title CREReceiver is the entrypoint for the CRE that forwards settlement payloads to the oracle coordinator.
/// @notice CRE entrypoint that forwards settlement payloads.
contract CREReceiver is ReceiverTemplate {
    OracleCoordinator public oracleCoordinator;

    event OracleCoordinatorUpdated(address indexed previous, address indexed current);

    /// @notice Constructor for the CREReceiver.
    /// @param forwarderAddress The address of the forwarder.
    /// @param coordinator The address of the oracle coordinator.
    constructor(address forwarderAddress, address coordinator) ReceiverTemplate(forwarderAddress) {
        oracleCoordinator = OracleCoordinator(coordinator);
    }

    /// @notice Set the oracle coordinator.
    /// @param coordinator The address of the oracle coordinator.
    function setOracleCoordinator(address coordinator) external onlyOwner {
        address previous = address(oracleCoordinator);
        oracleCoordinator = OracleCoordinator(coordinator);
        emit OracleCoordinatorUpdated(previous, coordinator);
    }

    /// @notice Process the report from the CRE.
    /// @param report The report from the CRE.
    function _processReport(bytes calldata report) internal override {
        // if the report is a session payload, submit the session to the oracle coordinator
        if (report.length > 0 && report[0] == 0x03) {
            oracleCoordinator.submitSession(report[1:]);
            return;
        }
        (address market, uint256 marketId, uint8 outcomeIndex, uint16 confidence) =
            abi.decode(report, (address, uint256, uint8, uint16));
        oracleCoordinator.submitResult(market, marketId, outcomeIndex, confidence);
    }
}
