// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ISettlementRouter} from "../interfaces/ISettlementRouter.sol";
import {Errors} from "../utils/Errors.sol";

/// @title OracleCoordinator is the coordinator for the oracle pipeline that routes validated oracle results to the settlement router.
/// @notice Dispatches validated oracle results to the settlement router.
contract OracleCoordinator is Ownable {
    address public creReceiver;
    address public settlementRouter;
    address public reportValidator;

    event CREReceiverUpdated(address indexed previous, address indexed current);
    event SettlementRouterUpdated(address indexed previous, address indexed current);
    event ReportValidatorUpdated(address indexed previous, address indexed current);

    modifier onlyReceiver() {
        _onlyReceiver();
        _;
    }

    function _onlyReceiver() internal view {
        if (msg.sender != creReceiver) revert Errors.Unauthorized();
    }

    constructor() Ownable(msg.sender) {}

    /// @notice Set the CRE receiver.
    /// @param receiver The address of the CRE receiver.
    function setCreReceiver(address receiver) external onlyOwner {
        address previous = creReceiver;
        creReceiver = receiver;
        emit CREReceiverUpdated(previous, receiver);
    }

    /// @notice Set the settlement router.
    /// @param router The address of the settlement router.
    function setSettlementRouter(address router) external onlyOwner {
        address previous = settlementRouter;
        settlementRouter = router;
        emit SettlementRouterUpdated(previous, router);
    }

    /// @notice Set the report validator.
    /// @param validator The address of the report validator.
    function setReportValidator(address validator) external onlyOwner {
        address previous = reportValidator;
        reportValidator = validator;
        emit ReportValidatorUpdated(previous, validator);
    }

    /// @notice Submit the result to the settlement router to be settled in the prediction market.
    /// @param market The address of the market.
    /// @param marketId The ID of the market.
    /// @param outcomeIndex The index of the outcome.
    /// @param confidence The confidence of the result.
    function submitResult(address market, uint256 marketId, uint8 outcomeIndex, uint16 confidence)
        external
        onlyReceiver
    {
        // if the report validator is set, validate the confidence by calling the validate function
        if (reportValidator != address(0)) {
            (bool ok, ) = reportValidator.call(abi.encodeWithSignature("validate(uint16)", confidence));
            if (!ok) revert Errors.InvalidConfidence();
        }
        ISettlementRouter(settlementRouter).settleMarket(market, marketId, outcomeIndex, confidence);
    }

    function submitSession(bytes calldata payload) external onlyReceiver {
        ISettlementRouter(settlementRouter).finalizeSession(payload);
    }
}
