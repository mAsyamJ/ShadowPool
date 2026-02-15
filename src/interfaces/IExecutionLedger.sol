// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ShadowTypes} from "../libs/ShadowTypes.sol";

interface IExecutionLedger {
    function positionOf(address user, uint256 marketId, uint32 outcomeIndex) external view returns (int256);

    /// @notice Apply deltas (only ChannelSettlement calls).
    function applyDeltas(uint256 marketId, bytes32 sessionId, ShadowTypes.Delta[] calldata deltas) external;
}
