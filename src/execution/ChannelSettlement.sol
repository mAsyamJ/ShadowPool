// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
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
import {ILiquidityVault4626} from "../interfaces/ILiquidityVault4626.sol";
import {IOutcomeToken1155} from "../interfaces/IOutcomeToken1155.sol";
import {IMarketRiskManager} from "../interfaces/IMarketRiskManager.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title ChannelSettlement
/// @notice Checkpoint-based Yellow session settlement with nonce monotonicity and challenge window.
contract ChannelSettlement is ShadowEIP712, Ownable, IChannelSettlement {
    using SafeCast for int256;

    error InvalidLiquidityVaultAsset();

    ICollateralVault public immutable VAULT;
    IMultiAssetVault public multiAssetVault;
    IExecutionLedger public immutable LEDGER;
    IOutcomeToken1155 public outcomeToken;
    IMarketRiskManager public riskManager;
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
    event OutcomeTokenUpdated(address indexed previous, address indexed current);
    event RiskManagerUpdated(address indexed previous, address indexed current);

    constructor(address vault_, address ledger_, address operator_) Ownable(msg.sender) {
        VAULT = ICollateralVault(vault_);
        LEDGER = IExecutionLedger(ledger_);
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

    function setOutcomeToken(address ot) external onlyOwner {
        address previous = address(outcomeToken);
        outcomeToken = IOutcomeToken1155(ot);
        emit OutcomeTokenUpdated(previous, ot);
    }

    function setRiskManager(address rm) external onlyOwner {
        address previous = address(riskManager);
        riskManager = IMarketRiskManager(rm);
        emit RiskManagerUpdated(previous, rm);
    }

    function _key(uint256 marketId, bytes32 sessionId) internal pure returns (bytes32) {
        bytes32 key;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, marketId)
            mstore(add(ptr, 0x20), sessionId)
            key := keccak256(ptr, 0x40)
        }
        return key;
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

        address op = operator;
        if (_recoverCheckpointSigner(cp, operatorSig) != op) revert Errors.BadOperatorSig();

        bytes32 digest = _digestCheckpoint(cp);
        uint256 usersLen = users.length;
        for (uint256 i = 0; i < usersLen; i++) {
            if (ECDSA.recover(digest, userSigs[i]) != users[i]) revert Errors.BadUserSig();
        }

        // Signer coverage: users[] must be unique and contain every unique delta user
        uint256 deltasLen = deltas.length;
        for (uint256 i = 0; i < usersLen; i++) {
            for (uint256 j = i + 1; j < usersLen; j++) {
                if (users[i] == users[j]) revert Errors.DuplicateUsers();
            }
        }
        for (uint256 i = 0; i < deltasLen; i++) {
            address dUser = deltas[i].user;
            bool found;
            for (uint256 j = 0; j < usersLen; j++) {
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

        IMarketRegistry mr = marketRegistry;
        bool hasRegistry = address(mr) != address(0);

        // Market lifecycle binding: checkpoint.lastTradeAt must be <= market.tradingClose
        if (hasRegistry) {
            if (mr.status(marketId) == IMarketRegistry.Status.Resolved) {
                revert Errors.MarketAlreadyResolved();
            }
            uint48 tradingClose = mr.getTradingClose(marketId);
            if (tradingClose != 0 && p.lastTradeAt > tradingClose) {
                revert Errors.CheckpointAfterTradingClose();
            }
        }

        if (address(outcomeToken) != address(0)) {
            _applyShareDeltasAs1155(marketId, deltas);
        } else if (address(LEDGER) != address(0)) {
            LEDGER.applyDeltas(marketId, sessionId, deltas);
        } else {
            revert Errors.InvalidAddress();
        }

        (
            uint256 protocolFee,
            uint256 lpFee,
            uint256 creatorFee,
            int256 netTraderDelta,
            address settlementAsset
        ) = _applyCashDeltasAndFees(marketId, sessionId, deltas);

        address lpVault = hasRegistry ? mr.liquidityVaultByMarketId(marketId) : address(0);

        // Solvency invariant: market flagged as LP must have vault bound
        if (hasRegistry && mr.usesLpVaultByMarketId(marketId) && lpVault == address(0)) {
            revert Errors.LiquidityVaultRequired();
        }

        if (lpVault != address(0)) {
            address vaultAsset = ILiquidityVault4626(lpVault).asset();
            if (vaultAsset != settlementAsset) revert InvalidLiquidityVaultAsset();
        }

        // Net counterparty transfer: LP VAULT <-> TradingCashLedger
        if (lpVault != address(0)) {
            if (netTraderDelta > 0) {
                uint256 need = netTraderDelta.toUint256();
                uint256 bal = IERC20(settlementAsset).balanceOf(lpVault);
                if (bal < need) revert Errors.LpVaultInsolvent(need, bal);
                if (address(riskManager) != address(0)) {
                    riskManager.reserveLpPayout(marketId, need);
                }
                ILiquidityVault4626(lpVault).payToTradingLedger(
                    address(multiAssetVault) != address(0) ? address(multiAssetVault) : address(VAULT),
                    netTraderDelta.toUint256()
                );
            } else if (netTraderDelta < 0) {
                if (address(multiAssetVault) != address(0)) {
                    multiAssetVault.transferAsset(lpVault, settlementAsset, (-netTraderDelta).toUint256());
                } else {
                    VAULT.transferToFeeCollector(lpVault, (-netTraderDelta).toUint256());
                }
            }
        }

        // Fee routing
        if (protocolFee > 0 && address(feePool) != address(0) && feePool.feeCollector() == address(this)) {
            if (address(multiAssetVault) != address(0)) {
                multiAssetVault.transferAsset(address(feePool), settlementAsset, protocolFee);
            } else {
                VAULT.transferToFeeCollector(address(feePool), protocolFee);
            }
            feePool.recordFeeCollected(settlementAsset, protocolFee, marketId, sessionId);
        }
        if (lpFee > 0 && address(multiAssetVault) != address(0)) {
            if (lpVault != address(0) && ILiquidityVault4626(lpVault).totalSupply() > 0) {
                multiAssetVault.transferAsset(lpVault, settlementAsset, lpFee);
            } else if (address(feePool) != address(0) && feePool.treasuryPool() != address(0)) {
                multiAssetVault.transferAsset(feePool.treasuryPool(), settlementAsset, lpFee);
            }
        } else if (lpFee > 0) {
            if (lpVault != address(0) && ILiquidityVault4626(lpVault).totalSupply() > 0) {
                VAULT.transferToFeeCollector(lpVault, lpFee);
            } else if (address(feePool) != address(0) && feePool.treasuryPool() != address(0)) {
                VAULT.transferToFeeCollector(feePool.treasuryPool(), lpFee);
            }
        }
        if (creatorFee > 0 && hasRegistry) {
            address creator = mr.getCreator(marketId);
            if (creator != address(0)) {
                if (address(multiAssetVault) != address(0)) {
                    multiAssetVault.transferAsset(creator, settlementAsset, creatorFee);
                } else {
                    VAULT.transferToFeeCollector(creator, creatorFee);
                }
            }
        }

        latestNonceByKey[k] = p.nonce;
        delete pendingByKey[k];

        emit CheckpointFinalized(marketId, sessionId, p.nonce);
    }

    function _applyCashDeltasAndFees(
        uint256 marketId,
        bytes32 sessionId,
        ShadowTypes.Delta[] calldata deltas
    )
        internal
        returns (
            uint256 protocolFee,
            uint256 lpFee,
            uint256 creatorFee,
            int256 netTraderDelta,
            address settlementAsset
        )
    {
        address mav = address(multiAssetVault);
        IMarketRegistry mr = marketRegistry;
        FeeManager fm = feeManager;

        settlementAsset = mav != address(0) && address(mr) != address(0)
            ? mr.getSettlementAsset(marketId)
            : VAULT.token();

        uint256 deltasLen = deltas.length;
        address[] memory users = new address[](deltasLen);
        int128[] memory cashDeltas = new int128[](deltasLen);
        uint256 count = 0;
        netTraderDelta = 0;
        int256 rawSum = 0;

        for (uint256 i = 0; i < deltasLen; i++) {
            int128 delta = deltas[i].cashDelta;
            if (delta == 0) continue;

            rawSum += delta;
            int128 netDelta = delta;
            if (address(fm) != address(0) && delta > 0) {
                (uint256 pf, uint256 lf, uint256 cf, int128 nd) = fm.computeSplit(delta);
                protocolFee += pf;
                lpFee += lf;
                creatorFee += cf;
                netDelta = nd;
            }
            netTraderDelta += netDelta;
            users[count] = deltas[i].user;
            cashDeltas[count] = netDelta;
            count++;
        }

        uint256 feesTotal = protocolFee + lpFee + creatorFee;
        if (rawSum != netTraderDelta + int256(feesTotal)) revert Errors.BadCashAccounting();
        if (count > 0) {
            address[] memory usersTrimmed = new address[](count);
            int128[] memory cashDeltasTrimmed = new int128[](count);
            for (uint256 i = 0; i < count; i++) {
                usersTrimmed[i] = users[i];
                cashDeltasTrimmed[i] = cashDeltas[i];
            }
            if (mav != address(0)) {
                multiAssetVault.applyCashDeltas(settlementAsset, marketId, sessionId, usersTrimmed, cashDeltasTrimmed);
            } else {
                VAULT.applyCashDeltas(marketId, sessionId, usersTrimmed, cashDeltasTrimmed);
            }
        }
    }

    function _applyShareDeltasAs1155(uint256 marketId, ShadowTypes.Delta[] calldata deltas) internal {
        IOutcomeToken1155 ot = outcomeToken;
        for (uint256 i = 0; i < deltas.length; i++) {
            int128 sd = deltas[i].sharesDelta;
            if (sd == 0) continue;
            if (sd > 0) {
                ot.mint(deltas[i].user, marketId, deltas[i].outcomeIndex, uint256(int256(sd)));
            } else {
                ot.burn(deltas[i].user, marketId, deltas[i].outcomeIndex, uint256(int256(-sd)));
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

        address op = operator;
        if (_recoverCheckpointSigner(cp, operatorSig) != op) revert Errors.BadOperatorSig();

        bytes32 digest = _digestCheckpoint(cp);
        uint256 usersLen = users.length;
        for (uint256 i = 0; i < usersLen; i++) {
            if (ECDSA.recover(digest, userSigs[i]) != users[i]) revert Errors.BadUserSig();
        }

        // Signer coverage: users[] must be unique and contain every unique delta user
        uint256 deltasLen = deltas.length;
        for (uint256 i = 0; i < usersLen; i++) {
            for (uint256 j = i + 1; j < usersLen; j++) {
                if (users[i] == users[j]) revert Errors.DuplicateUsers();
            }
        }
        for (uint256 i = 0; i < deltasLen; i++) {
            address dUser = deltas[i].user;
            bool found;
            for (uint256 j = 0; j < usersLen; j++) {
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
