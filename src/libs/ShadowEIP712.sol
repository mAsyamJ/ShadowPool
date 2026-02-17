// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {ShadowTypes} from "./ShadowTypes.sol";

/// @title ShadowEIP712
/// @notice EIP-712 typed data signing for ShadowPool checkpoints and deltas.
abstract contract ShadowEIP712 is EIP712 {
    using ECDSA for bytes32;

    bytes32 internal constant CHECKPOINT_TYPEHASH =
        keccak256("Checkpoint(uint256 marketId,bytes32 sessionId,uint64 nonce,uint64 validAfter,uint64 validBefore,uint48 lastTradeAt,bytes32 stateHash,bytes32 deltasHash,bytes32 riskHash)");

    bytes32 internal constant DELTA_TYPEHASH =
        keccak256("Delta(address user,uint32 outcomeIndex,int128 sharesDelta,int128 cashDelta)");

    constructor() EIP712("ShadowPool", "1") {}

    function _hashDelta(ShadowTypes.Delta memory d) internal pure returns (bytes32) {
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

    function _hashDeltas(ShadowTypes.Delta[] memory deltas) internal pure returns (bytes32) {
        bytes32[] memory h = new bytes32[](deltas.length);
        for (uint256 i = 0; i < deltas.length; i++) {
            h[i] = _hashDelta(deltas[i]);
        }
        bytes32 digest;
        assembly ("memory-safe") {
            digest := keccak256(add(h, 0x20), shl(5, mload(h)))
        }
        return digest;
    }

    function _hashCheckpoint(ShadowTypes.Checkpoint memory cp) internal pure returns (bytes32) {
        bytes32 checkpointTypehash = CHECKPOINT_TYPEHASH;
        bytes32 digest;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, checkpointTypehash)
            mstore(add(ptr, 0x20), mload(cp))
            mstore(add(ptr, 0x40), mload(add(cp, 0x20)))
            mstore(add(ptr, 0x60), mload(add(cp, 0x40)))
            mstore(add(ptr, 0x80), mload(add(cp, 0x60)))
            mstore(add(ptr, 0xa0), mload(add(cp, 0x80)))
            mstore(add(ptr, 0xc0), mload(add(cp, 0xa0)))
            mstore(add(ptr, 0xe0), mload(add(cp, 0xc0)))
            mstore(add(ptr, 0x100), mload(add(cp, 0xe0)))
            mstore(add(ptr, 0x120), mload(add(cp, 0x100)))
            digest := keccak256(ptr, 0x140)
        }
        return digest;
    }

    function _digestCheckpoint(ShadowTypes.Checkpoint memory cp) internal view returns (bytes32) {
        return _hashTypedDataV4(_hashCheckpoint(cp));
    }

    function _recoverCheckpointSigner(
        ShadowTypes.Checkpoint memory cp,
        bytes memory signature
    ) internal view returns (address) {
        return _digestCheckpoint(cp).recover(signature);
    }
}
