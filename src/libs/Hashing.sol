// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ShadowTypes} from "./ShadowTypes.sol";

/// @title Hashing
/// @notice Pure hashing helpers for ShadowPool (used by libs and tests).
library Hashing {
    bytes32 internal constant DELTA_TYPEHASH =
        keccak256("Delta(address user,uint32 outcomeIndex,int128 sharesDelta,int128 cashDelta)");

    function hashDelta(ShadowTypes.Delta memory d) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(DELTA_TYPEHASH, d.user, d.outcomeIndex, d.sharesDelta, d.cashDelta)
        );
    }

    function hashDeltas(ShadowTypes.Delta[] memory deltas) internal pure returns (bytes32) {
        bytes32[] memory h = new bytes32[](deltas.length);
        for (uint256 i = 0; i < deltas.length; i++) {
            h[i] = hashDelta(deltas[i]);
        }
        return keccak256(abi.encodePacked(h));
    }
}
