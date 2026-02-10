// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ISettlementRouter} from "../interfaces/ISettlementRouter.sol";
import {ISessionFinalizer} from "../interfaces/ISessionFinalizer.sol";
import {Errors} from "../utils/Errors.sol";

interface IPredictionMarketReceiver {
    function onReport(bytes calldata metadata, bytes calldata report) external;
}

/// @title SettlementRouter is the router for the oracle pipeline that forwards validated oracle results to the prediction market.
/// @notice Forwards validated outcomes to PredictionMarket via onReport.
contract SettlementRouter is ISettlementRouter {
    address public oracleCoordinator;
    address public sessionFinalizer;

    event OracleCoordinatorUpdated(address indexed previous, address indexed current);
    event SessionFinalizerUpdated(address indexed previous, address indexed current);
    event MarketSettled(address indexed market, uint256 marketId, uint8 outcomeIndex, uint16 confidence);

    modifier onlyOracleCoordinator() {
        _onlyOracleCoordinator();
        _;
    }

    modifier onlySessionFinalizer() {
        _onlySessionFinalizer();
        _;
    }

    function _onlyOracleCoordinator() internal view {
        if (msg.sender != oracleCoordinator) revert Errors.Unauthorized();
    }

    function _onlySessionFinalizer() internal view {
        if (msg.sender != sessionFinalizer) revert Errors.Unauthorized();
    }

    /// @notice Set the oracle coordinator.
    /// @param coordinator The address of the oracle coordinator.
    function setOracleCoordinator(address coordinator) external {
        address previous = oracleCoordinator;
        oracleCoordinator = coordinator;
        emit OracleCoordinatorUpdated(previous, coordinator);
    }

    /// @notice Set the session finalizer.
    /// @param finalizer The address of the session finalizer.
    function setSessionFinalizer(address finalizer) external {
        address previous = sessionFinalizer;
        sessionFinalizer = finalizer;
        emit SessionFinalizerUpdated(previous, finalizer);
    }

    /// @notice Settle the market by forwarding the result to the prediction market.
    /// @param market The address of the market.
    /// @param marketId The ID of the market.
    /// @param outcomeIndex The index of the outcome.
    /// @param confidence The confidence of the result.
    function settleMarket(address market, uint256 marketId, uint8 outcomeIndex, uint16 confidence)
        external
        override
        onlyOracleCoordinator
    {
        // create the report for the market
        bytes memory report = bytes.concat(bytes1(0x01), abi.encode(marketId, outcomeIndex, confidence));
        // forward the report to the prediction market
        IPredictionMarketReceiver(market).onReport("", report);
        // emit the market settled event
        emit MarketSettled(market, marketId, outcomeIndex, confidence);
    }

    /// @notice Finalize the session by forwarding the payload to the session finalizer for yellow sessions.
    /// @param payload The payload to finalize the session.
    function finalizeSession(bytes calldata payload) external override onlyOracleCoordinator {
        // if the session finalizer is not set, revert
        if (sessionFinalizer == address(0)) revert Errors.InvalidAddress();
        // forward the payload to the session finalizer
        ISessionFinalizer(sessionFinalizer).finalizeSession(payload);
        // emit the market settled event
        emit MarketSettled(address(0), 0, 0, 0);
    }
}
