// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ISessionFinalizer} from "../interfaces/ISessionFinalizer.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {Errors} from "../utils/Errors.sol";

/// @title SessionFinalizer
/// @notice Validates Yellow session snapshots and pays participants in ERC-20.
contract SessionFinalizer is ISessionFinalizer, Ownable {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    error AlreadyFinalized();
    error InvalidPayload();
    error InvalidSignature();

    struct SessionPayload {
        uint256 marketId;
        bytes32 sessionId;
        address[] participants;
        uint256[] balances;
        bytes[] signatures;
        bytes backendSignature;
    }

    IERC20 public immutable TOKEN;
    address public trustedBackend;
    mapping(bytes32 => bool) public finalizedSessions;

    event TrustedBackendUpdated(address indexed previous, address indexed current);
    event SessionFinalized(uint256 indexed marketId, bytes32 indexed sessionId, address[] participants, uint256[] balances);

    constructor(address tokenAddress, address backendSigner) Ownable(msg.sender) {
        if (tokenAddress == address(0) || backendSigner == address(0)) revert Errors.InvalidAddress();
        TOKEN = IERC20(tokenAddress);
        trustedBackend = backendSigner;
    }

    /// @notice Set the trusted backend.
    /// @param backendSigner The address of the trusted backend.
    function setTrustedBackend(address backendSigner) external onlyOwner {
        if (backendSigner == address(0)) revert Errors.InvalidAddress();
        address previous = trustedBackend;
        trustedBackend = backendSigner;
        emit TrustedBackendUpdated(previous, backendSigner);
    }

    /// @notice Finalize the session.
    /// @param payload The payload to finalize the session.
    function finalizeSession(bytes calldata payload) external override {
        SessionPayload memory decoded = abi.decode(payload, (SessionPayload));
        // if the participants are empty, the balances are not equal to the participants, or the signatures are not equal to the participants, revert
        if (
            decoded.participants.length == 0 ||
            decoded.participants.length != decoded.balances.length ||
            decoded.participants.length != decoded.signatures.length
        ) {
            revert InvalidPayload();
        }
        // create the session key
        bytes32 sessionKey;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, mload(decoded))
            mstore(add(ptr, 0x20), mload(add(decoded, 0x20)))
            sessionKey := keccak256(ptr, 0x40)
        }
        // if the session is already finalized, revert
        if (finalizedSessions[sessionKey]) revert AlreadyFinalized();
        // create the state hash
        // verify the backend signature
        bytes32 stateHash = keccak256(
            abi.encode(decoded.marketId, decoded.sessionId, decoded.participants, decoded.balances)
        ).toEthSignedMessageHash();
        if (stateHash.recover(decoded.backendSignature) != trustedBackend) revert InvalidSignature();

        for (uint256 i = 0; i < decoded.participants.length; i++) {
            bytes32 userHash = keccak256(
                abi.encode(decoded.marketId, decoded.sessionId, decoded.participants[i], decoded.balances[i])
            ).toEthSignedMessageHash();
            if (userHash.recover(decoded.signatures[i]) != decoded.participants[i]) revert InvalidSignature();
        }

        finalizedSessions[sessionKey] = true;

        for (uint256 i = 0; i < decoded.participants.length; i++) {
            if (!TOKEN.transfer(decoded.participants[i], decoded.balances[i])) revert Errors.InvalidAmount();
        }

        emit SessionFinalized(decoded.marketId, decoded.sessionId, decoded.participants, decoded.balances);
    }
}
