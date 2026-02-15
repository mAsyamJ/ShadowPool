// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ICollateralVault} from "../interfaces/ICollateralVault.sol";
import {IExecutionLedger} from "../interfaces/IExecutionLedger.sol";
import {IMarketRegistry} from "../interfaces/IMarketRegistry.sol";
import {Errors} from "../utils/Errors.sol";

/// @title MarketRegistry
/// @notice Registry, resolution, and redeem-from-ledger for ShadowPool markets.
contract MarketRegistry is IMarketRegistry, Ownable {
    error MarketDoesNotExist();
    error MarketAlreadySettled();
    error MarketNotSettled();
    error InvalidOutcomeIndex();
    error InvalidOutcomeCount();
    error InvalidTimelineWindows();
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
        uint48 settledAt;
        bool settled;
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
    address public marketFactory;
    address public settlementRouter;

    ICollateralVault public immutable vault;
    IExecutionLedger public immutable ledger;

    constructor(address vault_, address ledger_) Ownable(msg.sender) {
        if (vault_ == address(0) || ledger_ == address(0)) revert Errors.InvalidAddress();
        vault = ICollateralVault(vault_);
        ledger = IExecutionLedger(ledger_);
    }

    function setMarketFactory(address factory) external onlyOwner {
        marketFactory = factory;
    }

    function setSettlementRouter(address router) external onlyOwner {
        settlementRouter = router;
    }

    function marketType(uint256 marketId) external view override returns (MarketType) {
        return marketTypeById[marketId];
    }

    function status(uint256 marketId) external view returns (Status) {
        Market memory m = markets[marketId];
        if (m.creator == address(0)) return Status.Draft;
        if (m.settled) return Status.Resolved;
        return Status.Active;
    }

    // ============ Create (IPredictionMarket compatible for MarketFactory) ============

    function createMarket(string memory question) public returns (uint256 marketId) {
        marketId = nextMarketId++;
        marketTypeById[marketId] = MarketType.Binary;
        markets[marketId] = Market({
            creator: msg.sender,
            createdAt: uint48(block.timestamp),
            settledAt: 0,
            settled: false,
            confidence: 0,
            outcome: Prediction.Yes,
            question: question
        });
        emit MarketCreated(marketId, question, msg.sender);
    }

    function createMarketFor(string memory question, address requestedBy) external returns (uint256 marketId) {
        if (msg.sender != marketFactory) revert UnauthorizedFactory();
        marketId = nextMarketId++;
        marketTypeById[marketId] = MarketType.Binary;
        markets[marketId] = Market({
            creator: requestedBy,
            createdAt: uint48(block.timestamp),
            settledAt: 0,
            settled: false,
            confidence: 0,
            outcome: Prediction.Yes,
            question: question
        });
        emit MarketCreated(marketId, question, requestedBy);
    }

    function createCategoricalMarket(string memory question, string[] memory outcomes) external returns (uint256 marketId) {
        marketId = nextMarketId++;
        _initTypedMarket(marketId, question, msg.sender, MarketType.Categorical, outcomes.length);
        categoricalOutcomes[marketId] = outcomes;
    }

    function createCategoricalMarketFor(
        string memory question,
        string[] memory outcomes,
        address requestedBy
    ) external returns (uint256 marketId) {
        if (msg.sender != marketFactory) revert UnauthorizedFactory();
        marketId = nextMarketId++;
        _initTypedMarket(marketId, question, requestedBy, MarketType.Categorical, outcomes.length);
        categoricalOutcomes[marketId] = outcomes;
    }

    function createTimelineMarket(string memory question, uint48[] memory windows) external returns (uint256 marketId) {
        marketId = nextMarketId++;
        _initTypedMarket(marketId, question, msg.sender, MarketType.Timeline, windows.length);
        _storeTimelineWindows(marketId, windows);
    }

    function createTimelineMarketFor(
        string memory question,
        uint48[] memory windows,
        address requestedBy
    ) external returns (uint256 marketId) {
        if (msg.sender != marketFactory) revert UnauthorizedFactory();
        marketId = nextMarketId++;
        _initTypedMarket(marketId, question, requestedBy, MarketType.Timeline, windows.length);
        _storeTimelineWindows(marketId, windows);
    }

    function _initTypedMarket(
        uint256 marketId,
        string memory question,
        address creator,
        MarketType mt,
        uint256 outcomesCount
    ) internal {
        if (outcomesCount < 2) revert InvalidOutcomeCount();
        marketTypeById[marketId] = mt;
        markets[marketId] = Market({
            creator: creator,
            createdAt: uint48(block.timestamp),
            settledAt: 0,
            settled: false,
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

    // ============ Resolve ============

    function resolve(uint256 marketId, uint32 winningOutcome, uint16 confidence) external override {
        _doResolve(marketId, winningOutcome, confidence);
    }

    function _doResolve(uint256 marketId, uint32 winningOutcome, uint16 confidence) internal {
        Market memory m = markets[marketId];
        if (m.creator == address(0)) revert MarketDoesNotExist();
        if (m.settled) revert MarketAlreadySettled();

        if (marketTypeById[marketId] == MarketType.Binary) {
            if (winningOutcome > 1) revert InvalidOutcomeIndex();
            markets[marketId].outcome = Prediction(uint8(winningOutcome));
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

        int256 shares = ledger.positionOf(msg.sender, marketId, winningOutcome);
        if (shares <= 0) revert NothingToRedeem();

        hasRedeemed[marketId][msg.sender] = true;
        payout = uint256(shares);
        vault.redeemPayout(msg.sender, payout);
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
