// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {ICollateralVault} from "../interfaces/ICollateralVault.sol";
import {IMultiAssetVault} from "../interfaces/IMultiAssetVault.sol";
import {IExecutionLedger} from "../interfaces/IExecutionLedger.sol";
import {IOutcomeToken1155} from "../interfaces/IOutcomeToken1155.sol";
import {IMarketRegistry} from "../interfaces/IMarketRegistry.sol";
import {Errors} from "../utils/Errors.sol";

/// @title MarketRegistry
/// @notice Registry, resolution, and redeem-from-LEDGER for ShadowPool markets.
contract MarketRegistry is IMarketRegistry, Ownable {
    using SafeCast for int256;
    error MarketDoesNotExist();
    error MarketAlreadySettled();
    error MarketNotSettled();
    error InvalidOutcomeIndex();
    error InvalidOutcomeCount();
    error InvalidTimelineWindows();
    error InvalidMarketTimes();
    error UnauthorizedFactory();
    error UnauthorizedRouter();
    error NothingToRedeem();
    error AlreadyRedeemed();
    error TransferFailed();

    event MarketCreated(uint256 indexed marketId, string question, address creator);
    event MarketCreatedTyped(uint256 indexed marketId, MarketType marketType, uint256 outcomesCount);
    event MarketResolved(uint256 indexed marketId, uint32 winningOutcome, uint16 confidence);
    event Redeemed(uint256 indexed marketId, address indexed user, uint256 amount);

    enum Prediction {
        Yes,
        No
    }

    struct Market {
        address creator;
        uint48 createdAt;
        uint48 expiry;       // Texpiry from whitepaper; 0 = no expiry enforced
        uint48 tradingOpen; // When trading opens; 0 = immediately
        uint48 tradingClose;// When trading closes; 0 = no enforcement (use expiry or max)
        uint48 resolveTime;  // When resolution allowed; 0 = anytime after close
        uint48 settledAt;
        bool settled;
        bool frozen;        // Set by freeze() when block.timestamp >= tradingClose
        uint16 confidence;
        Prediction outcome;
        string question;
    }

    uint256 internal nextMarketId;
    mapping(uint256 => Market) internal markets;
    mapping(uint256 => MarketType) public marketTypeById;
    mapping(uint256 => string[]) internal categoricalOutcomes;
    mapping(uint256 => uint48[]) internal timelineWindows;
    mapping(uint256 => uint32) public typedOutcomeIndex;
    mapping(uint256 => mapping(address => bool)) internal hasRedeemed;
    mapping(uint256 => address) public settlementAssetByMarketId;
    mapping(uint256 => address) public liquidityVaultByMarketId;
    mapping(uint256 => bool) public usesLpVaultByMarketId;
    address public marketFactory;
    address public settlementRouter;
    IMultiAssetVault public multiAssetVault;
    address public defaultSettlementAsset;

    ICollateralVault public immutable VAULT;
    IExecutionLedger public immutable LEDGER;
    IOutcomeToken1155 public outcomeToken;

    constructor(address vault_, address ledger_) Ownable(msg.sender) {
        if (vault_ == address(0)) revert Errors.InvalidAddress();
        VAULT = ICollateralVault(vault_);
        LEDGER = IExecutionLedger(ledger_);
    }

    function setOutcomeToken(address ot) external onlyOwner {
        outcomeToken = IOutcomeToken1155(ot);
    }

    function setMarketFactory(address factory) external onlyOwner {
        marketFactory = factory;
    }

    function setSettlementRouter(address router) external onlyOwner {
        settlementRouter = router;
    }

    function setMultiAssetVault(address vault_) external onlyOwner {
        multiAssetVault = IMultiAssetVault(vault_);
    }

    function setDefaultSettlementAsset(address asset) external onlyOwner {
        defaultSettlementAsset = asset;
    }

    /// @notice Returns settlement asset for market; 0 = use VAULT.token() (legacy).
    function getSettlementAsset(uint256 marketId) external view returns (address) {
        address a = settlementAssetByMarketId[marketId];
        if (a != address(0)) return a;
        if (address(multiAssetVault) != address(0) && defaultSettlementAsset != address(0)) {
            return defaultSettlementAsset;
        }
        return VAULT.token();
    }

    function marketType(uint256 marketId) external view override returns (MarketType) {
        return marketTypeById[marketId];
    }

    function status(uint256 marketId) external view returns (Status) {
        Market memory m = markets[marketId];
        if (m.creator == address(0)) return Status.Draft;
        if (m.settled) return Status.Resolved;
        if (m.frozen) return Status.Frozen;
        return Status.Open;
    }

    /// @notice Returns trading close timestamp for market; 0 means no enforcement.
    function getTradingClose(uint256 marketId) external view returns (uint48) {
        return markets[marketId].tradingClose;
    }

    /// @notice Returns creator for market (for settlement fee routing).
    function getCreator(uint256 marketId) external view returns (address) {
        return markets[marketId].creator;
    }

    /// @notice Set liquidity VAULT for market. Only MarketFactory.
    /// @dev usesLpVaultByMarketId is set true when a non-zero vault is bound and never cleared (defense-in-depth).
    function setLiquidityVault(uint256 marketId, address vaultAddr) external {
        if (msg.sender != marketFactory) revert UnauthorizedFactory();
        liquidityVaultByMarketId[marketId] = vaultAddr;
        if (vaultAddr != address(0)) {
            usesLpVaultByMarketId[marketId] = true;
        }
    }

    /// @notice Freeze market when block.timestamp >= tradingClose. Permissionless.
    function freeze(uint256 marketId) external {
        Market storage m = markets[marketId];
        if (m.creator == address(0)) revert MarketDoesNotExist();
        if (m.settled || m.frozen) return;
        if (m.tradingClose != 0 && block.timestamp >= m.tradingClose) {
            m.frozen = true;
        }
    }

    // ============ Create (IPredictionMarket compatible for MarketFactory) ============

    function createMarket(string memory question) public returns (uint256 marketId) {
        return createMarketWithExpiry(question, 0);
    }

    function createMarketWithExpiry(string memory question, uint48 expiry_) public returns (uint256 marketId) {
        marketId = nextMarketId++;
        marketTypeById[marketId] = MarketType.Binary;
        markets[marketId] = Market({
            creator: msg.sender,
            createdAt: uint48(block.timestamp),
            expiry: expiry_,
            tradingOpen: 0,
            tradingClose: expiry_,
            resolveTime: expiry_,
            settledAt: 0,
            settled: false,
            frozen: false,
            confidence: 0,
            outcome: Prediction.Yes,
            question: question
        });
        emit MarketCreated(marketId, question, msg.sender);
    }

    function createMarketFor(string memory question, address requestedBy) external returns (uint256 marketId) {
        return createMarketForWithExpiry(question, requestedBy, 0);
    }

    function createMarketForWithExpiry(string memory question, address requestedBy, uint48 expiry_) public returns (uint256 marketId) {
        return createMarketForWithExpiryAndAsset(question, requestedBy, expiry_, address(0));
    }

    function createMarketForWithExpiryAndAsset(
        string memory question,
        address requestedBy,
        uint48 expiry_,
        address settlementAsset_
    ) public returns (uint256 marketId) {
        if (msg.sender != marketFactory) revert UnauthorizedFactory();
        marketId = nextMarketId++;
        marketTypeById[marketId] = MarketType.Binary;
        markets[marketId] = Market({
            creator: requestedBy,
            createdAt: uint48(block.timestamp),
            expiry: expiry_,
            tradingOpen: 0,
            tradingClose: expiry_,
            resolveTime: expiry_,
            settledAt: 0,
            settled: false,
            frozen: false,
            confidence: 0,
            outcome: Prediction.Yes,
            question: question
        });
        if (settlementAsset_ != address(0)) settlementAssetByMarketId[marketId] = settlementAsset_;
        emit MarketCreated(marketId, question, requestedBy);
    }

    /// @notice Create binary market with explicit timing (curated path). Uses draft times exactly.
    function createMarketForWithFullParams(
        string memory question,
        address requestedBy,
        uint48 tradingOpen_,
        uint48 tradingClose_,
        uint48 resolveTime_,
        address settlementAsset_
    ) public returns (uint256 marketId) {
        if (msg.sender != marketFactory) revert UnauthorizedFactory();
        _validateTimes(tradingOpen_, tradingClose_, resolveTime_);
        uint48 expiry_ = resolveTime_ != 0 ? resolveTime_ : tradingClose_;
        marketId = nextMarketId++;
        marketTypeById[marketId] = MarketType.Binary;
        markets[marketId] = Market({
            creator: requestedBy,
            createdAt: uint48(block.timestamp),
            expiry: expiry_,
            tradingOpen: tradingOpen_,
            tradingClose: tradingClose_,
            resolveTime: resolveTime_,
            settledAt: 0,
            settled: false,
            frozen: false,
            confidence: 0,
            outcome: Prediction.Yes,
            question: question
        });
        if (settlementAsset_ != address(0)) settlementAssetByMarketId[marketId] = settlementAsset_;
        emit MarketCreated(marketId, question, requestedBy);
    }

    function createCategoricalMarket(string memory question, string[] memory outcomes) external returns (uint256 marketId) {
        return createCategoricalMarketWithExpiry(question, outcomes, 0);
    }

    function createCategoricalMarketWithExpiry(
        string memory question,
        string[] memory outcomes,
        uint48 expiry_
    ) public returns (uint256 marketId) {
        marketId = nextMarketId++;
        _initTypedMarket(marketId, question, msg.sender, MarketType.Categorical, outcomes.length, expiry_);
        categoricalOutcomes[marketId] = outcomes;
    }

    function createCategoricalMarketFor(
        string memory question,
        string[] memory outcomes,
        address requestedBy
    ) external returns (uint256 marketId) {
        return createCategoricalMarketForWithExpiry(question, outcomes, requestedBy, 0);
    }

    function createCategoricalMarketForWithExpiry(
        string memory question,
        string[] memory outcomes,
        address requestedBy,
        uint48 expiry_
    ) public returns (uint256 marketId) {
        return createCategoricalMarketForWithExpiryAndAsset(question, outcomes, requestedBy, expiry_, address(0));
    }

    function createCategoricalMarketForWithExpiryAndAsset(
        string memory question,
        string[] memory outcomes,
        address requestedBy,
        uint48 expiry_,
        address settlementAsset_
    ) public returns (uint256 marketId) {
        if (msg.sender != marketFactory) revert UnauthorizedFactory();
        marketId = nextMarketId++;
        _initTypedMarket(marketId, question, requestedBy, MarketType.Categorical, outcomes.length, expiry_);
        categoricalOutcomes[marketId] = outcomes;
        if (settlementAsset_ != address(0)) settlementAssetByMarketId[marketId] = settlementAsset_;
    }

    /// @notice Create categorical market with explicit timing (curated path).
    function createCategoricalMarketForWithFullParams(
        string memory question,
        string[] memory outcomes,
        address requestedBy,
        uint48 tradingOpen_,
        uint48 tradingClose_,
        uint48 resolveTime_,
        address settlementAsset_
    ) public returns (uint256 marketId) {
        if (msg.sender != marketFactory) revert UnauthorizedFactory();
        _validateTimes(tradingOpen_, tradingClose_, resolveTime_);
        uint48 expiry_ = resolveTime_ != 0 ? resolveTime_ : tradingClose_;
        marketId = nextMarketId++;
        _initTypedMarketWithFullParams(
            marketId,
            question,
            requestedBy,
            MarketType.Categorical,
            outcomes.length,
            tradingOpen_,
            tradingClose_,
            resolveTime_,
            expiry_
        );
        categoricalOutcomes[marketId] = outcomes;
        if (settlementAsset_ != address(0)) settlementAssetByMarketId[marketId] = settlementAsset_;
    }

    function createTimelineMarket(string memory question, uint48[] memory windows) external returns (uint256 marketId) {
        return createTimelineMarketWithExpiry(question, windows, 0);
    }

    function createTimelineMarketWithExpiry(
        string memory question,
        uint48[] memory windows,
        uint48 expiry_
    ) public returns (uint256 marketId) {
        marketId = nextMarketId++;
        _initTypedMarket(marketId, question, msg.sender, MarketType.Timeline, windows.length, expiry_);
        _storeTimelineWindows(marketId, windows);
    }

    function createTimelineMarketFor(
        string memory question,
        uint48[] memory windows,
        address requestedBy
    ) external returns (uint256 marketId) {
        return createTimelineMarketForWithExpiry(question, windows, requestedBy, 0);
    }

    function createTimelineMarketForWithExpiry(
        string memory question,
        uint48[] memory windows,
        address requestedBy,
        uint48 expiry_
    ) public returns (uint256 marketId) {
        return createTimelineMarketForWithExpiryAndAsset(question, windows, requestedBy, expiry_, address(0));
    }

    function createTimelineMarketForWithExpiryAndAsset(
        string memory question,
        uint48[] memory windows,
        address requestedBy,
        uint48 expiry_,
        address settlementAsset_
    ) public returns (uint256 marketId) {
        if (msg.sender != marketFactory) revert UnauthorizedFactory();
        marketId = nextMarketId++;
        _initTypedMarket(marketId, question, requestedBy, MarketType.Timeline, windows.length, expiry_);
        _storeTimelineWindows(marketId, windows);
        if (settlementAsset_ != address(0)) settlementAssetByMarketId[marketId] = settlementAsset_;
    }

    /// @notice Create timeline market with explicit timing (curated path).
    function createTimelineMarketForWithFullParams(
        string memory question,
        uint48[] memory windows,
        address requestedBy,
        uint48 tradingOpen_,
        uint48 tradingClose_,
        uint48 resolveTime_,
        address settlementAsset_
    ) public returns (uint256 marketId) {
        if (msg.sender != marketFactory) revert UnauthorizedFactory();
        _validateTimes(tradingOpen_, tradingClose_, resolveTime_);
        uint48 expiry_ = resolveTime_ != 0 ? resolveTime_ : tradingClose_;
        marketId = nextMarketId++;
        _initTypedMarketWithFullParams(
            marketId,
            question,
            requestedBy,
            MarketType.Timeline,
            windows.length,
            tradingOpen_,
            tradingClose_,
            resolveTime_,
            expiry_
        );
        _storeTimelineWindows(marketId, windows);
        if (settlementAsset_ != address(0)) settlementAssetByMarketId[marketId] = settlementAsset_;
    }

    function _initTypedMarket(
        uint256 marketId,
        string memory question,
        address creator,
        MarketType mt,
        uint256 outcomesCount,
        uint48 expiry_
    ) internal {
        if (outcomesCount < 2) revert InvalidOutcomeCount();
        marketTypeById[marketId] = mt;
        markets[marketId] = Market({
            creator: creator,
            createdAt: uint48(block.timestamp),
            expiry: expiry_,
            tradingOpen: 0,
            tradingClose: expiry_,
            resolveTime: expiry_,
            settledAt: 0,
            settled: false,
            frozen: false,
            confidence: 0,
            outcome: Prediction.Yes,
            question: question
        });
        emit MarketCreated(marketId, question, creator);
        emit MarketCreatedTyped(marketId, mt, outcomesCount);
    }

    function _initTypedMarketWithFullParams(
        uint256 marketId,
        string memory question,
        address creator,
        MarketType mt,
        uint256 outcomesCount,
        uint48 tradingOpen_,
        uint48 tradingClose_,
        uint48 resolveTime_,
        uint48 expiry_
    ) internal {
        if (outcomesCount < 2) revert InvalidOutcomeCount();
        marketTypeById[marketId] = mt;
        markets[marketId] = Market({
            creator: creator,
            createdAt: uint48(block.timestamp),
            expiry: expiry_,
            tradingOpen: tradingOpen_,
            tradingClose: tradingClose_,
            resolveTime: resolveTime_,
            settledAt: 0,
            settled: false,
            frozen: false,
            confidence: 0,
            outcome: Prediction.Yes,
            question: question
        });
        emit MarketCreated(marketId, question, creator);
        emit MarketCreatedTyped(marketId, mt, outcomesCount);
    }

    function _storeTimelineWindows(uint256 marketId, uint48[] memory windows) internal {
        if (windows.length < 2) revert InvalidOutcomeCount();
        for (uint256 i = 1; i < windows.length; i++) {
            if (windows[i] <= windows[i - 1]) revert InvalidTimelineWindows();
        }
        timelineWindows[marketId] = windows;
    }

    function _validateTimes(uint48 tradingOpen_, uint48 tradingClose_, uint48 resolveTime_) internal pure {
        if (tradingOpen_ != 0 && tradingClose_ != 0 && tradingClose_ < tradingOpen_) revert InvalidMarketTimes();
        if (tradingClose_ != 0 && resolveTime_ != 0 && resolveTime_ < tradingClose_) revert InvalidMarketTimes();
    }

    // ============ Resolve ============

    /// @notice Resolve market; callable only by SettlementRouter.
    function resolve(uint256 marketId, uint32 winningOutcome, uint16 confidence) external override {
        if (msg.sender != settlementRouter) revert UnauthorizedRouter();
        _doResolve(marketId, winningOutcome, confidence);
    }

    function _doResolve(uint256 marketId, uint32 winningOutcome, uint16 confidence) internal {
        Market memory m = markets[marketId];
        if (m.creator == address(0)) revert MarketDoesNotExist();
        if (m.settled) revert MarketAlreadySettled();

        if (marketTypeById[marketId] == MarketType.Binary) {
            if (winningOutcome > 1) revert InvalidOutcomeIndex();
            markets[marketId].outcome = winningOutcome == 0 ? Prediction.Yes : Prediction.No;
        } else {
            if (marketTypeById[marketId] == MarketType.Categorical) {
                if (winningOutcome >= categoricalOutcomes[marketId].length) revert InvalidOutcomeIndex();
            } else if (marketTypeById[marketId] == MarketType.Timeline) {
                if (winningOutcome >= timelineWindows[marketId].length) revert InvalidOutcomeIndex();
            }
            typedOutcomeIndex[marketId] = winningOutcome;
        }

        markets[marketId].settled = true;
        markets[marketId].confidence = confidence;
        markets[marketId].settledAt = uint48(block.timestamp);
        emit MarketResolved(marketId, winningOutcome, confidence);
    }

    // ============ Redeem (from ExecutionLedger) ============

    function redeem(uint256 marketId) external override returns (uint256 payout) {
        Market memory m = markets[marketId];
        if (m.creator == address(0)) revert MarketDoesNotExist();
        if (!m.settled) revert MarketNotSettled();
        if (hasRedeemed[marketId][msg.sender]) revert AlreadyRedeemed();

        uint32 winningOutcome;
        if (marketTypeById[marketId] == MarketType.Binary) {
            winningOutcome = uint32(uint8(m.outcome));
        } else {
            winningOutcome = typedOutcomeIndex[marketId];
        }

        if (address(outcomeToken) != address(0)) {
            uint256 tokenId = outcomeToken.id(marketId, winningOutcome);
            payout = outcomeToken.balanceOf(msg.sender, tokenId);
            if (payout == 0) revert NothingToRedeem();
            hasRedeemed[marketId][msg.sender] = true;
            outcomeToken.burnForRedeem(msg.sender, marketId, winningOutcome, payout);
        } else {
            int256 shares = LEDGER.positionOf(msg.sender, marketId, winningOutcome);
            if (shares <= 0) revert NothingToRedeem();
            hasRedeemed[marketId][msg.sender] = true;
            payout = shares.toUint256();
        }

        address asset = this.getSettlementAsset(marketId);
        if (address(multiAssetVault) != address(0)) {
            multiAssetVault.redeemPayout(msg.sender, asset, payout);
        } else {
            VAULT.redeemPayout(msg.sender, payout);
        }
        emit Redeemed(marketId, msg.sender, payout);
    }

    function getMarket(uint256 marketId) external view returns (Market memory) {
        return markets[marketId];
    }

    function getCategoricalOutcomes(uint256 marketId) external view returns (string[] memory) {
        return categoricalOutcomes[marketId];
    }

    function getTimelineWindows(uint256 marketId) external view returns (uint48[] memory) {
        return timelineWindows[marketId];
    }

    /// @notice CRE receiver entrypoint for settlement reports (0x01 prefix).
    /// @dev Called by SettlementRouter; decodes and resolves.
    function onReport(bytes calldata, bytes calldata report) external {
        if (msg.sender != settlementRouter) revert UnauthorizedRouter();
        if (report.length < 1 || report[0] != 0x01) return;
        (uint256 marketId, uint32 outcomeIndex, uint16 confidence) =
            abi.decode(report[1:], (uint256, uint32, uint16));
        _doResolve(marketId, outcomeIndex, confidence);
    }
}
