// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ShadowTypes} from "../libs/ShadowTypes.sol";
import {ShadowEIP712} from "../libs/ShadowEIP712.sol";
import {ICollateralVault} from "../interfaces/ICollateralVault.sol";
import {IExecutionLedger} from "../interfaces/IExecutionLedger.sol";
import {IChannelSettlement} from "../interfaces/IChannelSettlement.sol";

/// @title ChannelSettlement
/// @notice Checkpoint-based Yellow session settlement with nonce monotonicity and challenge window.
contract ChannelSettlement is ShadowEIP712, Ownable, IChannelSettlement {
    ICollateralVault public immutable vault;
    IExecutionLedger public immutable ledger;

    address public operator;

    uint32 public constant MAX_DELTAS = 256;
    uint32 public constant MAX_USERS = 256;
    uint32 public constant CHALLENGE_WINDOW_SECONDS = 30 * 60; // 30 minutes

    struct Pending {
        uint64 nonce;
        uint64 challengeDeadline;
        bytes32 stateHash;
        bytes32 deltasHash;
        bytes32 riskHash;
        bool exists;
    }

    mapping(bytes32 => uint64) public latestNonceByKey;
    mapping(bytes32 => Pending) public pendingByKey;

    event CheckpointSubmitted(
        uint256 indexed marketId,
        bytes32 indexed sessionId,
        uint64 nonce,
        bytes32 stateHash,
        bytes32 deltasHash
    );
    event CheckpointChallenged(uint256 indexed marketId, bytes32 indexed sessionId, uint64 newNonce);
    event CheckpointFinalized(uint256 indexed marketId, bytes32 indexed sessionId, uint64 nonce);

    constructor(address vault_, address ledger_, address operator_) Ownable(msg.sender) {
        vault = ICollateralVault(vault_);
        ledger = IExecutionLedger(ledger_);
        operator = operator_;
    }

    function setOperator(address op) external onlyOwner {
        if (op == address(0)) revert();
        operator = op;
    }

    function _key(uint256 marketId, bytes32 sessionId) internal pure returns (bytes32) {
        return keccak256(abi.encode(marketId, sessionId));
    }

    function latestNonce(uint256 marketId, bytes32 sessionId) external view returns (uint64) {
        return latestNonceByKey[_key(marketId, sessionId)];
    }

    /// @notice For test/offchain: get EIP-712 digest for a checkpoint.
    function digestCheckpoint(ShadowTypes.Checkpoint memory cp) external view returns (bytes32) {
        return _digestCheckpoint(cp);
    }

    function submitCheckpointFromPayload(bytes calldata payload) external override {
        (
            ShadowTypes.Checkpoint memory cp,
            ShadowTypes.Delta[] memory deltas,
            bytes memory operatorSig,
            address[] memory users,
            bytes[] memory userSigs
        ) = abi.decode(payload, (ShadowTypes.Checkpoint, ShadowTypes.Delta[], bytes, address[], bytes[]));
        _submitCheckpointMem(cp, deltas, operatorSig, users, userSigs);
    }

    function submitCheckpoint(
        ShadowTypes.Checkpoint calldata cp,
        ShadowTypes.Delta[] calldata deltas,
        bytes calldata operatorSig,
        address[] calldata users,
        bytes[] calldata userSigs
    ) external {
        _submitCheckpoint(cp, deltas, operatorSig, users, userSigs);
    }

    function _submitCheckpoint(
        ShadowTypes.Checkpoint calldata cp,
        ShadowTypes.Delta[] calldata deltas,
        bytes calldata operatorSig,
        address[] calldata users,
        bytes[] calldata userSigs
    ) internal {
        _verifyAndStorePending(cp, deltas, operatorSig, users, userSigs, false);
        emit CheckpointSubmitted(cp.marketId, cp.sessionId, cp.nonce, cp.stateHash, cp.deltasHash);
    }

    function _submitCheckpointMem(
        ShadowTypes.Checkpoint memory cp,
        ShadowTypes.Delta[] memory deltas,
        bytes memory operatorSig,
        address[] memory users,
        bytes[] memory userSigs
    ) internal {
        _verifyAndStorePendingMem(cp, deltas, operatorSig, users, userSigs, false);
        emit CheckpointSubmitted(cp.marketId, cp.sessionId, cp.nonce, cp.stateHash, cp.deltasHash);
    }

    function _verifyAndStorePendingMem(
        ShadowTypes.Checkpoint memory cp,
        ShadowTypes.Delta[] memory deltas,
        bytes memory operatorSig,
        address[] memory users,
        bytes[] memory userSigs,
        bool isChallenge
    ) internal {
        if (deltas.length > MAX_DELTAS) revert("TOO_MANY_DELTAS");
        if (users.length > MAX_USERS) revert("TOO_MANY_USERS");
        if (users.length != userSigs.length) revert("SIG_LEN");

        bytes32 dHash = _hashDeltas(deltas);
        if (dHash != cp.deltasHash) revert("BAD_DELTAS_HASH");

        if (cp.validAfter != 0 && block.timestamp < cp.validAfter) revert("TOO_EARLY");
        if (cp.validBefore != 0 && block.timestamp > cp.validBefore) revert("TOO_LATE");

        if (_recoverCheckpointSigner(cp, operatorSig) != operator) revert("BAD_OPERATOR_SIG");

        bytes32 digest = _digestCheckpoint(cp);
        for (uint256 i = 0; i < users.length; i++) {
            if (ECDSA.recover(digest, userSigs[i]) != users[i]) revert("BAD_USER_SIG");
        }

        bytes32 key = _key(cp.marketId, cp.sessionId);
        uint64 latest = latestNonceByKey[key];
        if (cp.nonce <= latest) revert("NONCE_NOT_INCREASING");

        Pending storage p = pendingByKey[key];

        if (isChallenge) {
            if (!p.exists) revert("NO_PENDING_TO_CHALLENGE");
            if (block.timestamp >= p.challengeDeadline) revert("WINDOW_PASSED");
            if (cp.nonce <= p.nonce) revert("CHALLENGE_NOT_NEWER");
        }

        p.nonce = cp.nonce;
        p.stateHash = cp.stateHash;
        p.deltasHash = cp.deltasHash;
        p.riskHash = cp.riskHash;
        p.challengeDeadline = uint64(block.timestamp) + CHALLENGE_WINDOW_SECONDS;
        p.exists = true;
    }

    function challengeCheckpoint(
        ShadowTypes.Checkpoint calldata newerCp,
        ShadowTypes.Delta[] calldata newerDeltas,
        bytes calldata operatorSig,
        address[] calldata users,
        bytes[] calldata userSigs
    ) external {
        _verifyAndStorePending(newerCp, newerDeltas, operatorSig, users, userSigs, true);
        emit CheckpointChallenged(newerCp.marketId, newerCp.sessionId, newerCp.nonce);
    }

    function finalizeCheckpoint(
        uint256 marketId,
        bytes32 sessionId,
        ShadowTypes.Delta[] calldata deltas
    ) external {
        bytes32 k = _key(marketId, sessionId);
        Pending memory p = pendingByKey[k];
        if (!p.exists) revert("NO_PENDING");
        if (block.timestamp < p.challengeDeadline) revert("CHALLENGE_WINDOW");

        bytes32 dHash = _hashDeltas(deltas);
        if (dHash != p.deltasHash) revert("BAD_DELTAS_HASH");

        ledger.applyDeltas(marketId, sessionId, deltas);

        address[] memory users = new address[](deltas.length);
        int128[] memory cashDeltas = new int128[](deltas.length);
        uint256 count = 0;
        for (uint256 i = 0; i < deltas.length; i++) {
            if (deltas[i].cashDelta != 0) {
                users[count] = deltas[i].user;
                cashDeltas[count] = deltas[i].cashDelta;
                count++;
            }
        }
        if (count > 0) {
            address[] memory usersTrimmed = new address[](count);
            int128[] memory cashDeltasTrimmed = new int128[](count);
            for (uint256 i = 0; i < count; i++) {
                usersTrimmed[i] = users[i];
                cashDeltasTrimmed[i] = cashDeltas[i];
            }
            vault.applyCashDeltas(marketId, sessionId, usersTrimmed, cashDeltasTrimmed);
        }

        latestNonceByKey[k] = p.nonce;
        delete pendingByKey[k];

        emit CheckpointFinalized(marketId, sessionId, p.nonce);
    }

    function _verifyAndStorePending(
        ShadowTypes.Checkpoint calldata cp,
        ShadowTypes.Delta[] calldata deltas,
        bytes calldata operatorSig,
        address[] calldata users,
        bytes[] calldata userSigs,
        bool isChallenge
    ) internal {
        if (deltas.length > MAX_DELTAS) revert("TOO_MANY_DELTAS");
        if (users.length > MAX_USERS) revert("TOO_MANY_USERS");
        if (users.length != userSigs.length) revert("SIG_LEN");

        bytes32 dHash = _hashDeltas(deltas);
        if (dHash != cp.deltasHash) revert("BAD_DELTAS_HASH");

        if (cp.validAfter != 0 && block.timestamp < cp.validAfter) revert("TOO_EARLY");
        if (cp.validBefore != 0 && block.timestamp > cp.validBefore) revert("TOO_LATE");

        if (_recoverCheckpointSigner(cp, operatorSig) != operator) revert("BAD_OPERATOR_SIG");

        bytes32 digest = _digestCheckpoint(cp);
        for (uint256 i = 0; i < users.length; i++) {
            if (ECDSA.recover(digest, userSigs[i]) != users[i]) revert("BAD_USER_SIG");
        }

        bytes32 key = _key(cp.marketId, cp.sessionId);
        uint64 latest = latestNonceByKey[key];
        if (cp.nonce <= latest) revert("NONCE_NOT_INCREASING");

        Pending storage p = pendingByKey[key];

        if (isChallenge) {
            if (!p.exists) revert("NO_PENDING_TO_CHALLENGE");
            if (block.timestamp >= p.challengeDeadline) revert("WINDOW_PASSED");
            if (cp.nonce <= p.nonce) revert("CHALLENGE_NOT_NEWER");
        }

        p.nonce = cp.nonce;
        p.stateHash = cp.stateHash;
        p.deltasHash = cp.deltasHash;
        p.riskHash = cp.riskHash;
        p.challengeDeadline = uint64(block.timestamp) + CHALLENGE_WINDOW_SECONDS;
        p.exists = true;
    }
}
