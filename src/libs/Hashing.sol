// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ShadowTypes} from "./ShadowTypes.sol";

/// @title Hashing
/// @notice Pure hashing helpers for ShadowPool (used by libs and tests).
library Hashing {
    bytes32 internal constant DELTA_TYPEHASH =
        keccak256("Delta(address user,uint32 outcomeIndex,int128 sharesDelta,int128 cashDelta)");

    function hashDelta(ShadowTypes.Delta memory d) internal pure returns (bytes32) {
        bytes32 typeHash = DELTA_TYPEHASH;
        bytes32 digest;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, typeHash)
            mstore(add(ptr, 0x20), mload(d))
            mstore(add(ptr, 0x40), mload(add(d, 0x20)))
            mstore(add(ptr, 0x60), mload(add(d, 0x40)))
            mstore(add(ptr, 0x80), mload(add(d, 0x60)))
            digest := keccak256(ptr, 0xa0)
        }
        return digest;
    }

    function hashDeltas(ShadowTypes.Delta[] memory deltas) internal pure returns (bytes32) {
        bytes32[] memory h = new bytes32[](deltas.length);
        for (uint256 i = 0; i < deltas.length; i++) {
            h[i] = hashDelta(deltas[i]);
        }
        bytes32 digest;
        assembly ("memory-safe") {
            digest := keccak256(add(h, 0x20), shl(5, mload(h)))
        }
        return digest;
    }
}
