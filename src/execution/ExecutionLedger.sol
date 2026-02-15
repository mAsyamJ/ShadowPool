// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ShadowTypes} from "../libs/ShadowTypes.sol";
import {IExecutionLedger} from "../interfaces/IExecutionLedger.sol";
import {Errors} from "../utils/Errors.sol";

/// @title ExecutionLedger
/// @notice Canonical positions ledger for ShadowPool; no pricing, only position storage.
contract ExecutionLedger is IExecutionLedger, Ownable {
    address public channelSettlement;

    // positionOf[keccak256(user, marketId, outcomeIndex)] => int256
    mapping(bytes32 => int256) private _positions;

    event DeltasApplied(uint256 indexed marketId, bytes32 indexed sessionId, uint256 deltaCount);
    event ChannelSettlementUpdated(address indexed previous, address indexed current);

    error OnlyChannelSettlement();
    error NegativePosition();

    constructor(address channelSettlement_) Ownable(msg.sender) {
        channelSettlement = channelSettlement_;
    }

    function setChannelSettlement(address channelSettlement_) external onlyOwner {
        if (channelSettlement_ == address(0)) revert Errors.InvalidAddress();
        address previous = channelSettlement;
        channelSettlement = channelSettlement_;
        emit ChannelSettlementUpdated(previous, channelSettlement_);
    }

    function positionOf(address user, uint256 marketId, uint32 outcomeIndex) external view override returns (int256) {
        return _positions[_posKey(user, marketId, outcomeIndex)];
    }

    function applyDeltas(
        uint256 marketId,
        bytes32 sessionId,
        ShadowTypes.Delta[] calldata deltas
    ) external override {
        if (msg.sender != channelSettlement) revert OnlyChannelSettlement();

        for (uint256 i = 0; i < deltas.length; i++) {
            ShadowTypes.Delta calldata d = deltas[i];
            bytes32 key = _posKey(d.user, marketId, d.outcomeIndex);
            int256 current = _positions[key];
            int256 next = current + int256(d.sharesDelta);
            if (next < 0) revert NegativePosition();
            _positions[key] = next;
        }
        emit DeltasApplied(marketId, sessionId, deltas.length);
    }

    function _posKey(address user, uint256 marketId, uint32 outcomeIndex) internal pure returns (bytes32) {
        return keccak256(abi.encode(user, marketId, outcomeIndex));
    }
}
