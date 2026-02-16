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
        return keccak256(
            abi.encode(DELTA_TYPEHASH, d.user, d.outcomeIndex, d.sharesDelta, d.cashDelta)
        );
    }

    function _hashDeltas(ShadowTypes.Delta[] memory deltas) internal pure returns (bytes32) {
        bytes32[] memory h = new bytes32[](deltas.length);
        for (uint256 i = 0; i < deltas.length; i++) {
            h[i] = _hashDelta(deltas[i]);
        }
        return keccak256(abi.encodePacked(h));
    }

    function _hashCheckpoint(ShadowTypes.Checkpoint memory cp) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                CHECKPOINT_TYPEHASH,
                cp.marketId,
                cp.sessionId,
                cp.nonce,
                cp.validAfter,
                cp.validBefore,
                cp.lastTradeAt,
                cp.stateHash,
                cp.deltasHash,
                cp.riskHash
            )
        );
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
