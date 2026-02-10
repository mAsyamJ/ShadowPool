// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ReceiverTemplate} from "../interfaces/ReceiverTemplate.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title PredictionMarket
/// @notice A simplified Prediction Market contract for CRE.
/// @dev This contract hold markets, user positions, and pools, and pays out winners.
///      It also serves as a CRE receiver for a subset of workflows.
contract PredictionMarket is ReceiverTemplate {

    // errors for market operations
    error MarketDoesNotExist();
    error MarketAlreadySettled();
    error MarketNotSettled();
    error AlreadyPredicted();
    error InvalidAmount();
    error NothingToClaim();
    error AlreadyClaimed();
    error TransferFailed();
    error UnauthorizedFactory(); 
    error InvalidMarketType(); // invalid market type for binary, categorical, and timeline markets
    error InvalidOutcomeIndex(); // invalid outcome index for categorical and timeline markets
    error InvalidOutcomeCount(); 
    error InvalidTimelineWindows(); // invalid timeline windows for timeline markets

    // events for market operations
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

    // state variables for the prediction market
    uint256 internal nextMarketId; // the next market ID to be created
    mapping(uint256 marketId => Market market) internal markets;
    mapping(uint256 marketId => mapping(address user => UserPrediction)) internal predictions;
    mapping(uint256 marketId => mapping(address user => TypedPrediction)) internal typedPredictions;
    mapping(uint256 marketId => MarketType) public marketTypeById;
    mapping(uint256 marketId => string[]) internal categoricalOutcomes;
    mapping(uint256 marketId => uint256[]) internal categoricalPools;
    mapping(uint256 marketId => uint48[]) internal timelineWindows;
    mapping(uint256 marketId => uint256[]) internal timelinePools;
    mapping(uint256 marketId => uint8) public typedOutcomeIndex;
    address public marketFactory;
    IERC20 public immutable TOKEN;

    /// @notice ERC-20 token used for predictions and payouts.
    address public constant TOKEN_ADDRESS = 0x3600000000000000000000000000000000000000; // Change to USDC Sepolia from GHO for testnet

    /// @notice Constructor sets the Chainlink Forwarder address for security
    /// @param _forwarderAddress The address of the Chainlink KeystoneForwarder contract
    /// @dev For Sepolia testnet, use: 0x15fc6ae953e024d975e77382eeec56a9101f9f88
    constructor(address _forwarderAddress) ReceiverTemplate(_forwarderAddress) {
        TOKEN = IERC20(TOKEN_ADDRESS);
    }

    /// @notice Set the MarketFactory address allowed to create markets on behalf of users.
    function setMarketFactory(address factory) external onlyOwner {
        address previous = marketFactory;
        marketFactory = factory;
        emit MarketFactoryUpdated(previous, factory);
    }

    // ================================================================
    // │                       Create market                          │
    // ================================================================

    /// @notice Create a new prediction market.
    /// @param question The question for the market.
    /// @return marketId The ID of the newly created market.
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

    /// @notice Create a market from the MarketFactory with an explicit creator.
    /// @dev Reverts if caller is not the configured MarketFactory.
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

    /// @notice Create a categorical market with multiple outcomes.
    function createCategoricalMarket(string memory question, string[] memory outcomes) external returns (uint256 marketId) {
        marketId = nextMarketId++;
        _initTypedMarket(marketId, question, msg.sender, MarketType.Categorical, outcomes.length);
        categoricalOutcomes[marketId] = outcomes;
        categoricalPools[marketId] = new uint256[](outcomes.length);
    }

    /// @notice Create a categorical market from the MarketFactory.
    function createCategoricalMarketFor(
        string memory question,
        string[] memory outcomes,
        address requestedBy
    ) external returns (uint256 marketId) {
        if (msg.sender != marketFactory) revert UnauthorizedFactory();
        // create the market
        marketId = nextMarketId++;
        // initialize the market
        _initTypedMarket(marketId, question, requestedBy, MarketType.Categorical, outcomes.length);
        // store the outcomes
        categoricalOutcomes[marketId] = outcomes;
        // initialize the pools
        categoricalPools[marketId] = new uint256[](outcomes.length);
    }

    /// @notice Create a timeline market with multiple windows.
    function createTimelineMarket(string memory question, uint48[] memory windows) external returns (uint256 marketId) {
        marketId = nextMarketId++;
        _initTypedMarket(marketId, question, msg.sender, MarketType.Timeline, windows.length);
        _storeTimelineWindows(marketId, windows);
    }

    /// @notice Create a timeline market from the MarketFactory.
    function createTimelineMarketFor(
        string memory question,
        uint48[] memory windows,
        address requestedBy
    ) external returns (uint256 marketId) {
        if (msg.sender != marketFactory) revert UnauthorizedFactory();
        marketId = nextMarketId++;
        // initialize the market
        _initTypedMarket(marketId, question, requestedBy, MarketType.Timeline, windows.length);
        // store the windows
        _storeTimelineWindows(marketId, windows);
    }

    /// @notice Initialize a typed market (categorical or timeline).
    /// @param marketId The ID of the market.
    /// @param question The question for the market.
    /// @param creator The creator of the market.
    /// @param marketType The type of the market (categorical or timeline).
    /// @param outcomesCount The number of outcomes for the market.
    /// @dev Reverts if the outcomes count is less than 2.
    ///      - The market type must be binary, categorical, or timeline.
    ///      - The outcomes count must be at least 2.
    ///      - The market type must be set in the marketTypeById mapping.
    ///      - The market must be initialized with the creator, question, and market type.
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

    /// @notice Store the timeline windows for a timeline market.
    /// @param marketId The ID of the market.
    /// @param windows The timeline windows.
    /// @dev Reverts if the windows are not valid.
    ///      - The windows must be sorted in ascending order.
    ///      - The windows must be at least 2.
    ///      - The windows must not be in the past.
    function _storeTimelineWindows(uint256 marketId, uint48[] memory windows) internal {
        if (windows.length < 2) revert InvalidOutcomeCount();
        for (uint256 i = 1; i < windows.length; i++) {
            if (windows[i] <= windows[i - 1]) revert InvalidTimelineWindows();
        }
        timelineWindows[marketId] = windows;
        timelinePools[marketId] = new uint256[](windows.length);
    }

    // ================================================================
    // │                          Predict                             │
    // ================================================================

    /// @notice Make a prediction on a market.
    /// @param marketId The ID of the market.
    /// @param prediction The prediction (Yes or No).
    function predict(uint256 marketId, Prediction prediction, uint256 amount) external {
        Market memory m = markets[marketId];

        if (m.creator == address(0)) revert MarketDoesNotExist();
        if (m.settled) revert MarketAlreadySettled();
        if (marketTypeById[marketId] != MarketType.Binary) revert InvalidMarketType();
        if (amount == 0) revert InvalidAmount();

        // check if the user has already predicted
        UserPrediction memory userPred = predictions[marketId][msg.sender];
        if (userPred.amount != 0) revert AlreadyPredicted();

        // update the user's prediction
        predictions[marketId][msg.sender] = UserPrediction({
            amount: amount,
            prediction: prediction,
            claimed: false
        });

        // update the market's pools
        if (prediction == Prediction.Yes) {
            markets[marketId].totalYesPool += amount;
        } else {
            markets[marketId].totalNoPool += amount;
        }

        // transfer the tokens from the user to the market
        if (!TOKEN.transferFrom(msg.sender, address(this), amount)) revert TransferFailed();

        // emit the prediction made event
        emit PredictionMade(marketId, msg.sender, prediction, amount);
    }

    /// @notice Make a prediction on a categorical or timeline market.
    function predictOutcome(uint256 marketId, uint8 outcomeIndex, uint256 amount) external {
        // check if the market exists
        Market memory m = markets[marketId];

        if (m.creator == address(0)) revert MarketDoesNotExist();
        if (m.settled) revert MarketAlreadySettled();
        if (marketTypeById[marketId] == MarketType.Binary) revert InvalidMarketType();
        if (amount == 0) revert InvalidAmount();

        // check if the user has already predicted
        TypedPrediction memory userPred = typedPredictions[marketId][msg.sender];
        if (userPred.amount != 0) revert AlreadyPredicted();

        // update the market's pools
        // update the categorical pools
        if (marketTypeById[marketId] == MarketType.Categorical) {
            if (outcomeIndex >= categoricalPools[marketId].length) revert InvalidOutcomeIndex();
            // update amount in the categorical pool for the outcome index in the categorical pools array
            categoricalPools[marketId][outcomeIndex] += amount;
        // update the timeline pools
        } else {
            if (outcomeIndex >= timelinePools[marketId].length) revert InvalidOutcomeIndex();
            // update amount in the timeline pool for the outcome index in the timeline pools array
            timelinePools[marketId][outcomeIndex] += amount;
        }

        typedPredictions[marketId][msg.sender] = TypedPrediction({
            amount: amount,
            outcomeIndex: outcomeIndex, // outcome index is the index of the outcome in the categorical or timeline pools array
            claimed: false
        });

        if (!TOKEN.transferFrom(msg.sender, address(this), amount)) revert TransferFailed();

        emit PredictionMadeTyped(marketId, msg.sender, outcomeIndex, amount);
    }

    // ================================================================
    // │                    Request settlement                        │
    // ================================================================

    /// @notice Request settlement for a market.
    /// @dev Emits SettlementRequested event for CRE Log Trigger.
    /// @param marketId The ID of the market to settle.
    function requestSettlement(uint256 marketId) external {
        Market memory m = markets[marketId];

        if (m.creator == address(0)) revert MarketDoesNotExist();
        if (m.settled) revert MarketAlreadySettled();

        emit SettlementRequested(marketId, m.question);
    }

    // ================================================================
    // │                 Market settlement by CRE                     │
    // ================================================================

    /// @notice Settles a market from a CRE report with AI-determined outcome.
    /// @dev Called via onReport → _processReport when prefix byte is 0x01.
    /// @param report ABI-encoded (uint256 marketId, uint8 outcomeIndex, uint16 confidence)
    function _settleMarket(bytes calldata report) internal {
        // decode the report from the CRE report
        (uint256 marketId, uint8 outcomeIndex, uint16 confidence) = abi.decode(
            report,
            (uint256, uint8, uint16)
        );

        // check if the market exists
        Market memory m = markets[marketId];

        if (m.creator == address(0)) revert MarketDoesNotExist();
        if (m.settled) revert MarketAlreadySettled();

        // mark the market as settled
        markets[marketId].settled = true;
        // store the confidence
        markets[marketId].confidence = confidence;
        markets[marketId].settledAt = uint48(block.timestamp);

        // check if the market is binary
        if (marketTypeById[marketId] == MarketType.Binary) {
            if (outcomeIndex > 1) revert InvalidOutcomeIndex();
            // set the outcome of the market to the outcome index
            markets[marketId].outcome = Prediction(outcomeIndex);
            // emit the market settled event
            emit MarketSettled(marketId, Prediction(outcomeIndex), confidence);
        } else {
            // check if the market is categorical
            if (marketTypeById[marketId] == MarketType.Categorical) {
                if (outcomeIndex >= categoricalPools[marketId].length) revert InvalidOutcomeIndex();
                // set the outcome index of the market to the outcome index
            } else if (marketTypeById[marketId] == MarketType.Timeline) {
                if (outcomeIndex >= timelinePools[marketId].length) revert InvalidOutcomeIndex();
            } else {
                revert InvalidMarketType();
            }
            typedOutcomeIndex[marketId] = outcomeIndex;
            emit MarketSettledTyped(marketId, outcomeIndex, confidence);
        }
    }

    // ================================================================
    // │                      CRE Entry Point                         │
    // ================================================================

    /// @inheritdoc ReceiverTemplate
    /// @dev Routes to either market creation or settlement based on prefix byte.
    ///      - No prefix → Create market (Day 1)
    ///      - Prefix 0x01 → Settle market (Day 2)
    function _processReport(bytes calldata report) internal override {
        if (report.length > 0 && report[0] == 0x01) {
            _settleMarket(report[1:]);
        } else {
            string memory question = abi.decode(report, (string));
            createMarket(question);
        }
    }

    // ================================================================
    // │                      Claim winnings                          │
    // ================================================================

    /// @notice Claim winnings after market settlement.
    /// @param marketId The ID of the market.
    function claim(uint256 marketId) external {
        Market memory m = markets[marketId];

        if (m.creator == address(0)) revert MarketDoesNotExist();
        if (!m.settled) revert MarketNotSettled();

        // check if the market is binary
        if (marketTypeById[marketId] == MarketType.Binary) {
            // get the user's prediction
            UserPrediction memory userPred = predictions[marketId][msg.sender];

            if (userPred.amount == 0) revert NothingToClaim();
            // check if the user has already claimed
            if (userPred.claimed) revert AlreadyClaimed();
            if (userPred.prediction != m.outcome) revert NothingToClaim();

            // mark the user's prediction as claimed
            predictions[marketId][msg.sender].claimed = true;

            // get the total pool for the binary market
            uint256 totalPoolBinary = m.totalYesPool + m.totalNoPool;
            // get the winning pool for the binary market
            uint256 winningPoolBinary = m.outcome == Prediction.Yes ? m.totalYesPool : m.totalNoPool;
            if (winningPoolBinary == 0) revert NothingToClaim();
            // calculate the payout for the user
            uint256 payoutBinary = (userPred.amount * totalPoolBinary) / winningPoolBinary;

            // transfer the payout to the user
            if (!TOKEN.transfer(msg.sender, payoutBinary)) revert TransferFailed();

            emit WinningsClaimed(marketId, msg.sender, payoutBinary);
            return;
        }

        // get the user's prediction
        TypedPrediction memory typedPred = typedPredictions[marketId][msg.sender];
        // check if the user has a prediction
        if (typedPred.amount == 0) revert NothingToClaim();
        // check if the user has already claimed
        if (typedPred.claimed) revert AlreadyClaimed();
        // check if the user's outcome index matches the outcome index of the market
        if (typedPred.outcomeIndex != typedOutcomeIndex[marketId]) revert NothingToClaim();

        // mark the user's prediction as claimed
        typedPredictions[marketId][msg.sender].claimed = true;

        /// @dev check if the market is categorical section of code
        // get the total pool for the typed market
        uint256 totalPoolTyped = 0;
        // get the winning pool for the typed market
        uint256 winningPoolTyped = 0;
        // check if the market is categorical
        if (marketTypeById[marketId] == MarketType.Categorical) {
            // get the pools for the categorical market
            uint256[] storage pools = categoricalPools[marketId];
            for (uint256 i = 0; i < pools.length; i++) {
                // add the pool to the total pool for the categorical market
                totalPoolTyped += pools[i];
            }
            // get the winning pool for the categorical market
            winningPoolTyped = pools[typedOutcomeIndex[marketId]];
        // check if the market is timeline
        } else if (marketTypeById[marketId] == MarketType.Timeline) {
            // get the pools for the timeline market
            uint256[] storage pools = timelinePools[marketId];
            for (uint256 i = 0; i < pools.length; i++) {
                // add the pool to the total pool for the timeline market
                totalPoolTyped += pools[i];
            }
            // get the winning pool for the timeline market
            winningPoolTyped = pools[typedOutcomeIndex[marketId]];
        } else {
            revert InvalidMarketType();
        }

        // check if the winning pool is 0
        if (winningPoolTyped == 0) revert NothingToClaim(); /// @notice if the winning pool is 0, revert and users will not be able to claim winnings (update it so user get their amount back)
        // calculate the payout for the user
        uint256 payoutTyped = (typedPred.amount * totalPoolTyped) / winningPoolTyped;

        // transfer the payout to the user
        if (!TOKEN.transfer(msg.sender, payoutTyped)) revert TransferFailed();

        emit WinningsClaimed(marketId, msg.sender, payoutTyped);
    }

    // ================================================================
    // │                          Getters                             │
    // ================================================================

    /// @notice Get market details.
    /// @param marketId The ID of the market.
    function getMarket(uint256 marketId) external view returns (Market memory) {
        return markets[marketId];
    }

    /// @notice Get user's prediction for a market.
    /// @param marketId The ID of the market.
    /// @param user The user's address.
    function getPrediction(uint256 marketId, address user) external view returns (UserPrediction memory) {
        return predictions[marketId][user];
    }

    /// @notice Get the type of a market.
    /// @param marketId The ID of the market.
    /// @return The type of the market.
    function getMarketType(uint256 marketId) external view returns (MarketType) {
        return marketTypeById[marketId];
    }

    /// @notice Get the outcomes of a categorical market.
    /// @param marketId The ID of the market.
    /// @return The outcomes of the market.
    function getCategoricalOutcomes(uint256 marketId) external view returns (string[] memory) {
        return categoricalOutcomes[marketId];
    }

    /// @notice Get the windows of a timeline market.
    /// @param marketId The ID of the market.
    /// @return The windows of the market.
    function getTimelineWindows(uint256 marketId) external view returns (uint48[] memory) {
        return timelineWindows[marketId];
    }

    /// @notice Get the pools of a categorical market.
    /// @param marketId The ID of the market.
    /// @return The pools of the market.
    function getCategoricalPools(uint256 marketId) external view returns (uint256[] memory) {
        return categoricalPools[marketId];
    }

    /// @notice Get the pools of a timeline market.
    /// @param marketId The ID of the market.
    /// @return The pools of the market.
    function getTimelinePools(uint256 marketId) external view returns (uint256[] memory) {
        return timelinePools[marketId];
    }

    /// @notice Get the prediction of a user for a market.
    /// @param marketId The ID of the market.
    /// @param user The user's address.
    /// @return The prediction of the user for the market.
    function getTypedPrediction(uint256 marketId, address user) external view returns (TypedPrediction memory) {
        return typedPredictions[marketId][user];
    }
}
