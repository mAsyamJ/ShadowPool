// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/// @title SigVerify
/// @notice Signature verification helpers for ShadowPool.
library SigVerify {
    function recover(bytes32 digest, bytes memory signature) internal pure returns (address) {
        return ECDSA.recover(digest, signature);
    }
}
