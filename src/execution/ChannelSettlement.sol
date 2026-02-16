// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ShadowTypes} from "../libs/ShadowTypes.sol";
import {ShadowEIP712} from "../libs/ShadowEIP712.sol";
import {ICollateralVault} from "../interfaces/ICollateralVault.sol";
import {IMultiAssetVault} from "../interfaces/IMultiAssetVault.sol";
import {IExecutionLedger} from "../interfaces/IExecutionLedger.sol";
import {IChannelSettlement} from "../interfaces/IChannelSettlement.sol";
import {IMarketRegistry} from "../interfaces/IMarketRegistry.sol";
import {Errors} from "../utils/Errors.sol";
import {FeeManager} from "../fees/FeeManager.sol";
import {FeePool} from "../fees/FeePool.sol";

/// @title ChannelSettlement
/// @notice Checkpoint-based Yellow session settlement with nonce monotonicity and challenge window.
contract ChannelSettlement is ShadowEIP712, Ownable, IChannelSettlement {
    ICollateralVault public immutable vault;
    IMultiAssetVault public multiAssetVault;
    IExecutionLedger public immutable ledger;
    IMarketRegistry public marketRegistry;
    FeeManager public feeManager;
    FeePool public feePool;

    address public operator;

    uint32 public constant MAX_DELTAS = 256;
    uint32 public constant MAX_USERS = 256;
    uint32 public constant CHALLENGE_WINDOW_SECONDS = 30 * 60; // 30 minutes

    struct Pending {
        uint64 nonce;
        uint64 challengeDeadline;
        uint48 lastTradeAt;
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
    event MarketRegistryUpdated(address indexed previous, address indexed current);
    event FeeManagerUpdated(address indexed previous, address indexed current);
    event FeePoolUpdated(address indexed previous, address indexed current);
    event MultiAssetVaultUpdated(address indexed previous, address indexed current);

    constructor(address vault_, address ledger_, address operator_) Ownable(msg.sender) {
        vault = ICollateralVault(vault_);
        ledger = IExecutionLedger(ledger_);
        operator = operator_;
    }

    function setOperator(address op) external onlyOwner {
        if (op == address(0)) revert Errors.InvalidAddress();
        operator = op;
    }

    function setMarketRegistry(address registry) external onlyOwner {
        address previous = address(marketRegistry);
        marketRegistry = IMarketRegistry(registry);
        emit MarketRegistryUpdated(previous, registry);
    }

    function setFeeManager(address fm) external onlyOwner {
        address previous = address(feeManager);
        feeManager = FeeManager(fm);
        emit FeeManagerUpdated(previous, fm);
    }

    function setFeePool(address fp) external onlyOwner {
        address previous = address(feePool);
        feePool = FeePool(fp);
        emit FeePoolUpdated(previous, fp);
    }

    function setMultiAssetVault(address mav) external onlyOwner {
        address previous = address(multiAssetVault);
        multiAssetVault = IMultiAssetVault(mav);
        emit MultiAssetVaultUpdated(previous, mav);
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
        if (deltas.length > MAX_DELTAS) revert Errors.TooManyDeltas();
        if (users.length > MAX_USERS) revert Errors.TooManyUsers();
        if (users.length != userSigs.length) revert Errors.SigLenMismatch();

        bytes32 dHash = _hashDeltas(deltas);
        if (dHash != cp.deltasHash) revert Errors.BadDeltasHash();

        if (cp.validAfter != 0 && block.timestamp < cp.validAfter) revert Errors.TooEarly();
        if (cp.validBefore != 0 && block.timestamp > cp.validBefore) revert Errors.TooLate();

        if (_recoverCheckpointSigner(cp, operatorSig) != operator) revert Errors.BadOperatorSig();

        bytes32 digest = _digestCheckpoint(cp);
        for (uint256 i = 0; i < users.length; i++) {
            if (ECDSA.recover(digest, userSigs[i]) != users[i]) revert Errors.BadUserSig();
        }

        // Signer coverage: users[] must be unique and contain every unique delta user
        for (uint256 i = 0; i < users.length; i++) {
            for (uint256 j = i + 1; j < users.length; j++) {
                if (users[i] == users[j]) revert Errors.DuplicateUsers();
            }
        }
        for (uint256 i = 0; i < deltas.length; i++) {
            address dUser = deltas[i].user;
            bool found;
            for (uint256 j = 0; j < users.length; j++) {
                if (users[j] == dUser) {
                    found = true;
                    break;
                }
            }
            if (!found) revert Errors.DeltaUserNotSigned();
        }

        bytes32 key = _key(cp.marketId, cp.sessionId);
        uint64 latest = latestNonceByKey[key];
        if (cp.nonce <= latest) revert Errors.NonceNotIncreasing();

        Pending storage p = pendingByKey[key];

        if (isChallenge) {
            if (!p.exists) revert Errors.NoPendingToChallenge();
            if (block.timestamp >= p.challengeDeadline) revert Errors.WindowPassed();
            if (cp.nonce <= p.nonce) revert Errors.ChallengeNotNewer();
        }

        p.nonce = cp.nonce;
        p.lastTradeAt = cp.lastTradeAt;
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
        if (!p.exists) revert Errors.NoPending();
        if (block.timestamp < p.challengeDeadline) revert Errors.ChallengeWindow();

        bytes32 dHash = _hashDeltas(deltas);
        if (dHash != p.deltasHash) revert Errors.BadDeltasHash();

        // Market lifecycle binding: checkpoint.lastTradeAt must be <= market.tradingClose
        if (address(marketRegistry) != address(0)) {
            if (marketRegistry.status(marketId) == IMarketRegistry.Status.Resolved) {
                revert Errors.MarketAlreadyResolved();
            }
            uint48 tradingClose = marketRegistry.getTradingClose(marketId);
            if (tradingClose != 0 && p.lastTradeAt > tradingClose) {
                revert Errors.CheckpointAfterTradingClose();
            }
        }

        ledger.applyDeltas(marketId, sessionId, deltas);

        (uint256 totalFee, address settlementAsset) =
            _applyCashDeltasAndFees(marketId, sessionId, deltas);

        if (totalFee > 0 && address(feePool) != address(0) && feePool.feeCollector() == address(this)) {
            if (address(multiAssetVault) != address(0)) {
                multiAssetVault.transferToFeeCollector(address(feePool), settlementAsset, totalFee);
            } else {
                vault.transferToFeeCollector(address(feePool), totalFee);
            }
            feePool.recordFeeCollected(settlementAsset, totalFee, marketId, sessionId);
        }

        latestNonceByKey[k] = p.nonce;
        delete pendingByKey[k];

        emit CheckpointFinalized(marketId, sessionId, p.nonce);
    }

    function _applyCashDeltasAndFees(
        uint256 marketId,
        bytes32 sessionId,
        ShadowTypes.Delta[] calldata deltas
    ) internal returns (uint256 totalFee, address settlementAsset) {
        settlementAsset = address(multiAssetVault) != address(0) && address(marketRegistry) != address(0)
            ? marketRegistry.getSettlementAsset(marketId)
            : vault.token();

        address[] memory users = new address[](deltas.length);
        int128[] memory cashDeltas = new int128[](deltas.length);
        uint256 count = 0;

        for (uint256 i = 0; i < deltas.length; i++) {
            int128 delta = deltas[i].cashDelta;
            if (delta == 0) continue;

            int128 netDelta = delta;
            if (address(feeManager) != address(0) && delta > 0) {
                (uint256 fee,) = feeManager.computeFee(delta);
                if (fee > 0) {
                    totalFee += fee;
                    netDelta = delta - int128(int256(fee));
                }
            }
            users[count] = deltas[i].user;
            cashDeltas[count] = netDelta;
            count++;
        }
        if (count > 0) {
            address[] memory usersTrimmed = new address[](count);
            int128[] memory cashDeltasTrimmed = new int128[](count);
            for (uint256 i = 0; i < count; i++) {
                usersTrimmed[i] = users[i];
                cashDeltasTrimmed[i] = cashDeltas[i];
            }
            if (address(multiAssetVault) != address(0)) {
                multiAssetVault.applyCashDeltas(settlementAsset, marketId, sessionId, usersTrimmed, cashDeltasTrimmed);
            } else {
                vault.applyCashDeltas(marketId, sessionId, usersTrimmed, cashDeltasTrimmed);
            }
        }
    }

    function _verifyAndStorePending(
        ShadowTypes.Checkpoint calldata cp,
        ShadowTypes.Delta[] calldata deltas,
        bytes calldata operatorSig,
        address[] calldata users,
        bytes[] calldata userSigs,
        bool isChallenge
    ) internal {
        if (deltas.length > MAX_DELTAS) revert Errors.TooManyDeltas();
        if (users.length > MAX_USERS) revert Errors.TooManyUsers();
        if (users.length != userSigs.length) revert Errors.SigLenMismatch();

        bytes32 dHash = _hashDeltas(deltas);
        if (dHash != cp.deltasHash) revert Errors.BadDeltasHash();

        if (cp.validAfter != 0 && block.timestamp < cp.validAfter) revert Errors.TooEarly();
        if (cp.validBefore != 0 && block.timestamp > cp.validBefore) revert Errors.TooLate();

        if (_recoverCheckpointSigner(cp, operatorSig) != operator) revert Errors.BadOperatorSig();

        bytes32 digest = _digestCheckpoint(cp);
        for (uint256 i = 0; i < users.length; i++) {
            if (ECDSA.recover(digest, userSigs[i]) != users[i]) revert Errors.BadUserSig();
        }

        // Signer coverage: users[] must be unique and contain every unique delta user
        for (uint256 i = 0; i < users.length; i++) {
            for (uint256 j = i + 1; j < users.length; j++) {
                if (users[i] == users[j]) revert Errors.DuplicateUsers();
            }
        }
        for (uint256 i = 0; i < deltas.length; i++) {
            address dUser = deltas[i].user;
            bool found;
            for (uint256 j = 0; j < users.length; j++) {
                if (users[j] == dUser) {
                    found = true;
                    break;
                }
            }
            if (!found) revert Errors.DeltaUserNotSigned();
        }

        bytes32 key = _key(cp.marketId, cp.sessionId);
        uint64 latest = latestNonceByKey[key];
        if (cp.nonce <= latest) revert Errors.NonceNotIncreasing();

        Pending storage p = pendingByKey[key];

        if (isChallenge) {
            if (!p.exists) revert Errors.NoPendingToChallenge();
            if (block.timestamp >= p.challengeDeadline) revert Errors.WindowPassed();
            if (cp.nonce <= p.nonce) revert Errors.ChallengeNotNewer();
        }

        p.nonce = cp.nonce;
        p.lastTradeAt = cp.lastTradeAt;
        p.stateHash = cp.stateHash;
        p.deltasHash = cp.deltasHash;
        p.riskHash = cp.riskHash;
        p.challengeDeadline = uint64(block.timestamp) + CHALLENGE_WINDOW_SECONDS;
        p.exists = true;
    }
}
