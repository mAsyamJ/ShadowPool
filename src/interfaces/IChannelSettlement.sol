// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ShadowTypes} from "../libs/ShadowTypes.sol";

interface IChannelSettlement {
    /// @notice Submit checkpoint from encoded payload (for CRE routing).
    function submitCheckpointFromPayload(bytes calldata payload) external;

    function submitCheckpoint(
        ShadowTypes.Checkpoint calldata cp,
        ShadowTypes.Delta[] calldata deltas,
        bytes calldata operatorSig,
        address[] calldata users,
        bytes[] calldata userSigs
    ) external;

    function challengeCheckpoint(
        ShadowTypes.Checkpoint calldata newerCp,
        ShadowTypes.Delta[] calldata newerDeltas,
        bytes calldata operatorSig,
        address[] calldata users,
        bytes[] calldata userSigs
    ) external;

    function finalizeCheckpoint(
        uint256 marketId,
        bytes32 sessionId,
        ShadowTypes.Delta[] calldata deltas
    ) external;

    function latestNonce(uint256 marketId, bytes32 sessionId) external view returns (uint64);
}
