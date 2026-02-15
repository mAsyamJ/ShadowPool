// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ReceiverTemplate} from "../interfaces/ReceiverTemplate.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title LegacyPoolMarket
/// @notice Optional demo: pool-based prediction market with pro-rata claim.
/// @dev Uses pool AMM; for ShadowPool path use MarketRegistry + ExecutionLedger.
contract LegacyPoolMarket is ReceiverTemplate {
    error MarketDoesNotExist();
    error MarketAlreadySettled();
    error MarketNotSettled();
    error AlreadyPredicted();
    error InvalidAmount();
    error NothingToClaim();
    error AlreadyClaimed();
    error TransferFailed();
    error UnauthorizedFactory();
    error InvalidMarketType();
    error InvalidOutcomeIndex();
    error InvalidOutcomeCount();
    error InvalidTimelineWindows();

    event MarketCreated(uint256 indexed marketId, string question, address creator);
    event PredictionMade(uint256 indexed marketId, address indexed predictor, Prediction prediction, uint256 amount);
    event MarketCreatedTyped(uint256 indexed marketId, MarketType marketType, uint256 outcomesCount);
    event PredictionMadeTyped(uint256 indexed marketId, address indexed predictor, uint8 outcomeIndex, uint256 amount);
    event SettlementRequested(uint256 indexed marketId, string question);
    event MarketSettled(uint256 indexed marketId, Prediction outcome, uint16 confidence);
    event MarketSettledTyped(uint256 indexed marketId, uint8 outcomeIndex, uint16 confidence);
    event WinningsClaimed(uint256 indexed marketId, address indexed claimer, uint256 amount);
    event MarketFactoryUpdated(address indexed previousFactory, address indexed newFactory);

    enum Prediction {
        Yes,
        No
    }

    enum MarketType {
        Binary,
        Categorical,
        Timeline
    }

    struct Market {
        address creator;
        uint48 createdAt;
        uint48 settledAt;
        bool settled;
        uint16 confidence;
        Prediction outcome;
        uint256 totalYesPool;
        uint256 totalNoPool;
        string question;
    }

    struct UserPrediction {
        uint256 amount;
        Prediction prediction;
        bool claimed;
    }

    struct TypedPrediction {
        uint256 amount;
        uint8 outcomeIndex;
        bool claimed;
    }

    uint256 internal nextMarketId;
    mapping(uint256 => Market) internal markets;
    mapping(uint256 => mapping(address => UserPrediction)) internal predictions;
    mapping(uint256 => mapping(address => TypedPrediction)) internal typedPredictions;
    mapping(uint256 => MarketType) public marketTypeById;
    mapping(uint256 => string[]) internal categoricalOutcomes;
    mapping(uint256 => uint256[]) internal categoricalPools;
    mapping(uint256 => uint48[]) internal timelineWindows;
    mapping(uint256 => uint256[]) internal timelinePools;
    mapping(uint256 => uint8) public typedOutcomeIndex;
    address public marketFactory;
    IERC20 public immutable TOKEN;

    address public constant TOKEN_ADDRESS = 0x3600000000000000000000000000000000000000;

    constructor(address _forwarderAddress) ReceiverTemplate(_forwarderAddress) {
        TOKEN = IERC20(TOKEN_ADDRESS);
    }

    function setMarketFactory(address factory) external onlyOwner {
        address previous = marketFactory;
        marketFactory = factory;
        emit MarketFactoryUpdated(previous, factory);
    }

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
            totalYesPool: 0,
            totalNoPool: 0,
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
            totalYesPool: 0,
            totalNoPool: 0,
            question: question
        });
        emit MarketCreated(marketId, question, requestedBy);
    }

    function createCategoricalMarket(string memory question, string[] memory outcomes) external returns (uint256 marketId) {
        marketId = nextMarketId++;
        _initTypedMarket(marketId, question, msg.sender, MarketType.Categorical, outcomes.length);
        categoricalOutcomes[marketId] = outcomes;
        categoricalPools[marketId] = new uint256[](outcomes.length);
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
        categoricalPools[marketId] = new uint256[](outcomes.length);
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
        MarketType marketType,
        uint256 outcomesCount
    ) internal {
        if (outcomesCount < 2) revert InvalidOutcomeCount();
        marketTypeById[marketId] = marketType;
        markets[marketId] = Market({
            creator: creator,
            createdAt: uint48(block.timestamp),
            settledAt: 0,
            settled: false,
            confidence: 0,
            outcome: Prediction.Yes,
            totalYesPool: 0,
            totalNoPool: 0,
            question: question
        });
        emit MarketCreated(marketId, question, creator);
        emit MarketCreatedTyped(marketId, marketType, outcomesCount);
    }

    function _storeTimelineWindows(uint256 marketId, uint48[] memory windows) internal {
        if (windows.length < 2) revert InvalidOutcomeCount();
        for (uint256 i = 1; i < windows.length; i++) {
            if (windows[i] <= windows[i - 1]) revert InvalidTimelineWindows();
        }
        timelineWindows[marketId] = windows;
        timelinePools[marketId] = new uint256[](windows.length);
    }

    function predict(uint256 marketId, Prediction prediction, uint256 amount) external {
        Market memory m = markets[marketId];
        if (m.creator == address(0)) revert MarketDoesNotExist();
        if (m.settled) revert MarketAlreadySettled();
        if (marketTypeById[marketId] != MarketType.Binary) revert InvalidMarketType();
        if (amount == 0) revert InvalidAmount();
        UserPrediction memory userPred = predictions[marketId][msg.sender];
        if (userPred.amount != 0) revert AlreadyPredicted();

        predictions[marketId][msg.sender] = UserPrediction({amount: amount, prediction: prediction, claimed: false});
        if (prediction == Prediction.Yes) {
            markets[marketId].totalYesPool += amount;
        } else {
            markets[marketId].totalNoPool += amount;
        }
        if (!TOKEN.transferFrom(msg.sender, address(this), amount)) revert TransferFailed();
        emit PredictionMade(marketId, msg.sender, prediction, amount);
    }

    function predictOutcome(uint256 marketId, uint8 outcomeIndex, uint256 amount) external {
        Market memory m = markets[marketId];
        if (m.creator == address(0)) revert MarketDoesNotExist();
        if (m.settled) revert MarketAlreadySettled();
        if (marketTypeById[marketId] == MarketType.Binary) revert InvalidMarketType();
        if (amount == 0) revert InvalidAmount();
        TypedPrediction memory userPred = typedPredictions[marketId][msg.sender];
        if (userPred.amount != 0) revert AlreadyPredicted();

        if (marketTypeById[marketId] == MarketType.Categorical) {
            if (outcomeIndex >= categoricalPools[marketId].length) revert InvalidOutcomeIndex();
            categoricalPools[marketId][outcomeIndex] += amount;
        } else {
            if (outcomeIndex >= timelinePools[marketId].length) revert InvalidOutcomeIndex();
            timelinePools[marketId][outcomeIndex] += amount;
        }
        typedPredictions[marketId][msg.sender] = TypedPrediction({
            amount: amount,
            outcomeIndex: outcomeIndex,
            claimed: false
        });
        if (!TOKEN.transferFrom(msg.sender, address(this), amount)) revert TransferFailed();
        emit PredictionMadeTyped(marketId, msg.sender, outcomeIndex, amount);
    }

    function requestSettlement(uint256 marketId) external {
        Market memory m = markets[marketId];
        if (m.creator == address(0)) revert MarketDoesNotExist();
        if (m.settled) revert MarketAlreadySettled();
        emit SettlementRequested(marketId, m.question);
    }

    function _settleMarket(bytes calldata report) internal {
        (uint256 marketId, uint8 outcomeIndex, uint16 confidence) = abi.decode(report, (uint256, uint8, uint16));
        Market memory m = markets[marketId];
        if (m.creator == address(0)) revert MarketDoesNotExist();
        if (m.settled) revert MarketAlreadySettled();

        markets[marketId].settled = true;
        markets[marketId].confidence = confidence;
        markets[marketId].settledAt = uint48(block.timestamp);

        if (marketTypeById[marketId] == MarketType.Binary) {
            if (outcomeIndex > 1) revert InvalidOutcomeIndex();
            markets[marketId].outcome = Prediction(outcomeIndex);
            emit MarketSettled(marketId, Prediction(outcomeIndex), confidence);
        } else {
            if (marketTypeById[marketId] == MarketType.Categorical) {
                if (outcomeIndex >= categoricalPools[marketId].length) revert InvalidOutcomeIndex();
            } else if (marketTypeById[marketId] == MarketType.Timeline) {
                if (outcomeIndex >= timelinePools[marketId].length) revert InvalidOutcomeIndex();
            } else {
                revert InvalidMarketType();
            }
            typedOutcomeIndex[marketId] = outcomeIndex;
            emit MarketSettledTyped(marketId, outcomeIndex, confidence);
        }
    }

    function _processReport(bytes calldata report) internal override {
        if (report.length > 0 && report[0] == 0x01) {
            _settleMarket(report[1:]);
        } else {
            string memory question = abi.decode(report, (string));
            createMarket(question);
        }
    }

    function claim(uint256 marketId) external {
        Market memory m = markets[marketId];
        if (m.creator == address(0)) revert MarketDoesNotExist();
        if (!m.settled) revert MarketNotSettled();

        if (marketTypeById[marketId] == MarketType.Binary) {
            UserPrediction memory userPred = predictions[marketId][msg.sender];
            if (userPred.amount == 0) revert NothingToClaim();
            if (userPred.claimed) revert AlreadyClaimed();
            if (userPred.prediction != m.outcome) revert NothingToClaim();
            predictions[marketId][msg.sender].claimed = true;

            uint256 totalPoolBinary = m.totalYesPool + m.totalNoPool;
            uint256 winningPoolBinary = m.outcome == Prediction.Yes ? m.totalYesPool : m.totalNoPool;
            if (winningPoolBinary == 0) revert NothingToClaim();
            uint256 payoutBinary = (userPred.amount * totalPoolBinary) / winningPoolBinary;
            if (!TOKEN.transfer(msg.sender, payoutBinary)) revert TransferFailed();
            emit WinningsClaimed(marketId, msg.sender, payoutBinary);
            return;
        }

        TypedPrediction memory typedPred = typedPredictions[marketId][msg.sender];
        if (typedPred.amount == 0) revert NothingToClaim();
        if (typedPred.claimed) revert AlreadyClaimed();
        if (typedPred.outcomeIndex != typedOutcomeIndex[marketId]) revert NothingToClaim();
        typedPredictions[marketId][msg.sender].claimed = true;

        uint256 totalPoolTyped = 0;
        uint256 winningPoolTyped = 0;
        if (marketTypeById[marketId] == MarketType.Categorical) {
            uint256[] storage pools = categoricalPools[marketId];
            for (uint256 i = 0; i < pools.length; i++) totalPoolTyped += pools[i];
            winningPoolTyped = pools[typedOutcomeIndex[marketId]];
        } else if (marketTypeById[marketId] == MarketType.Timeline) {
            uint256[] storage pools = timelinePools[marketId];
            for (uint256 i = 0; i < pools.length; i++) totalPoolTyped += pools[i];
            winningPoolTyped = pools[typedOutcomeIndex[marketId]];
        } else {
            revert InvalidMarketType();
        }
        if (winningPoolTyped == 0) revert NothingToClaim();
        uint256 payoutTyped = (typedPred.amount * totalPoolTyped) / winningPoolTyped;
        if (!TOKEN.transfer(msg.sender, payoutTyped)) revert TransferFailed();
        emit WinningsClaimed(marketId, msg.sender, payoutTyped);
    }

    function getMarket(uint256 marketId) external view returns (Market memory) {
        return markets[marketId];
    }
    function getPrediction(uint256 marketId, address user) external view returns (UserPrediction memory) {
        return predictions[marketId][user];
    }
    function getMarketType(uint256 marketId) external view returns (MarketType) {
        return marketTypeById[marketId];
    }
    function getCategoricalOutcomes(uint256 marketId) external view returns (string[] memory) {
        return categoricalOutcomes[marketId];
    }
    function getTimelineWindows(uint256 marketId) external view returns (uint48[] memory) {
        return timelineWindows[marketId];
    }
    function getCategoricalPools(uint256 marketId) external view returns (uint256[] memory) {
        return categoricalPools[marketId];
    }
    function getTimelinePools(uint256 marketId) external view returns (uint256[] memory) {
        return timelinePools[marketId];
    }
    function getTypedPrediction(uint256 marketId, address user) external view returns (TypedPrediction memory) {
        return typedPredictions[marketId][user];
    }
}
