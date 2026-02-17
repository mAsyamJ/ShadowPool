// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ReceiverTemplate} from "../interfaces/ReceiverTemplate.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {MarketDraftBoard} from "../curation/MarketDraftBoard.sol";
import {DraftClaimManager} from "../curation/DraftClaimManager.sol";
import {ILiquidityVault4626} from "../interfaces/ILiquidityVault4626.sol";

/// @notice Interface for the prediction market.
interface IPredictionMarket {
    /// @notice Create a market for a binary market.
    /// @param question The question of the market.
    /// @param requestedBy The address of the requested by.
    /// @return The ID of the newly created market.
    function createMarketFor(string memory question, address requestedBy) external returns (uint256);
    /// @notice Create a categorical market for a categorical market.
    /// @param question The question of the market.
    /// @param outcomes The outcomes of the market.
    /// @param requestedBy The address of the requested by.
    /// @return The ID of the newly created market.
    function createCategoricalMarketFor(string memory question, string[] memory outcomes, address requestedBy) external returns (uint256);
    /// @notice Create a timeline market for a timeline market.
    /// @param question The question of the market.
    /// @param windows The windows of the market.
    /// @param requestedBy The address of the requested by.
    /// @return The ID of the newly created market.
    function createTimelineMarketFor(string memory question, uint48[] memory windows, address requestedBy) external returns (uint256);

    /// @notice Create a market with expiry (whitepaper Texpiry). expiry=0 means no expiry enforced.
    function createMarketForWithExpiry(string memory question, address requestedBy, uint48 expiry) external returns (uint256);
    function createCategoricalMarketForWithExpiry(string memory question, string[] memory outcomes, address requestedBy, uint48 expiry)
        external
        returns (uint256);
    function createTimelineMarketForWithExpiry(string memory question, uint48[] memory windows, address requestedBy, uint48 expiry)
        external
        returns (uint256);
}

/// @notice Interface for MarketRegistry create methods (curated path).
interface IMarketRegistryCreate {
    function createMarketForWithExpiry(string memory question, address requestedBy, uint48 expiry) external returns (uint256);
    function createCategoricalMarketForWithExpiry(string memory question, string[] memory outcomes, address requestedBy, uint48 expiry)
        external
        returns (uint256);
    function createTimelineMarketForWithExpiry(string memory question, uint48[] memory windows, address requestedBy, uint48 expiry)
        external
        returns (uint256);
    function createMarketForWithFullParams(
        string memory question,
        address requestedBy,
        uint48 tradingOpen,
        uint48 tradingClose,
        uint48 resolveTime,
        address settlementAsset
    ) external returns (uint256);
    function createCategoricalMarketForWithFullParams(
        string memory question,
        string[] memory outcomes,
        address requestedBy,
        uint48 tradingOpen,
        uint48 tradingClose,
        uint48 resolveTime,
        address settlementAsset
    ) external returns (uint256);
    function createTimelineMarketForWithFullParams(
        string memory question,
        uint48[] memory windows,
        address requestedBy,
        uint48 tradingOpen,
        uint48 tradingClose,
        uint48 resolveTime,
        address settlementAsset
    ) external returns (uint256);
    function setLiquidityVault(uint256 marketId, address vault) external;
}

/// @title MarketFactory
/// @notice CRE receiver that deploys markets from validated feed inputs.
contract MarketFactory is ReceiverTemplate {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    /// @notice Errors for market operations.
    error InvalidMarketAddress();
    error InvalidRequestedBy();
    error InvalidQuestion();
    error DuplicateExternalId();
    error ResolveTimeInPast();
    error InvalidSignature();
    error InvalidMarketType();
    error InvalidOutcomeCount();
    error InvalidTimelineWindows();
    error UnauthorizedPublishReceiver();
    error CuratedPathNotConfigured();
    error DraftTimeMismatch();
    error SeededClaimRequired();
    error InvalidLiquidityVaultAsset();

    /// @notice Events for market operations.
    event MarketSpawned(
        uint256 indexed marketId,
        address indexed requestedBy,
        string question,
        uint48 resolveTime, 
        string category, /// @notice category of the market
        string source, /// @notice source of the market
        bytes32 externalId /// @notice external ID of the market
    );

    /// @notice Event for spawned typed markets.
    /// @param marketId The ID of the market.
    /// @param requestedBy The address of the requested by.
    /// @param marketType The type of the market.
    /// @param outcomesCount The number of outcomes in the market.
    /// @param externalId The external ID of the market.
    event MarketSpawnedTyped(
        uint256 indexed marketId,
        address indexed requestedBy,
        uint8 marketType,
        uint256 outcomesCount,
        bytes32 externalId
    );

    /// @notice Struct for market input for binary markets.
    /// @param question The question of the market.
    /// @param requestedBy The address of the requested by.
    /// @param resolveTime The resolve time of the market.
    /// @param category The category of the market.
    /// @param source The source of the market.
    /// @param externalId The external ID of the market.
    /// @param signature The signature of the market.
    struct MarketInput {
        string question;
        address requestedBy;
        uint48 resolveTime;
        string category;
        string source;
        bytes32 externalId;
        bytes signature;
    }

    /// @notice Struct for market input v2. The difference between v1 and v2 is that v2 allows for typed markets (categorical and timeline).
    /// @param question The question of the market.
    /// @param requestedBy The address of the requested by.
    /// @param resolveTime The resolve time of the market.
    /// @param category The category of the market.
    /// @param source The source of the market.
    /// @param externalId The external ID of the market.
    /// @param marketType The type of the market.
    /// @param outcomes The outcomes of the market.
    /// @param timelineWindows The windows of the market.
    /// @param signature The signature of the market.
    struct MarketInputV2 {
        string question;
        address requestedBy;
        uint48 resolveTime;
        string category;
        string source;
        bytes32 externalId;
        uint8 marketType;
        string[] outcomes;
        uint48[] timelineWindows;
        bytes signature;
    }

    /// @notice Struct for market metadata.
    /// @param requestedBy The address of the requested by.
    /// @param resolveTime The resolve time of the market.
    /// @param category The category of the market.
    /// @param source The source of the market.
    /// @param externalId The external ID of the market.
    /// @param marketType The type of the market.
    /// @param outcomesCount The number of outcomes in the market.
    struct MarketMetadata {
        address requestedBy;
        uint48 resolveTime;
        string category;
        string source;
        bytes32 externalId;
        uint8 marketType;
        uint8 outcomesCount;
    }

    /// @notice Struct for publish-from-draft params (curated path).
    struct DraftPublishParams {
        string question;
        uint8 marketType;
        string[] outcomes;
        uint48[] timelineWindows;
        uint48 resolveTime;
        uint48 tradingOpen;
        uint48 tradingClose;
    }

    IPredictionMarket public immutable PREDICTION_MARKET;
    uint256 public minQuestionLength = 10;
    uint256 public maxQuestionLength = 200;

    IMarketRegistryCreate public marketRegistry;
    MarketDraftBoard public draftBoard;
    DraftClaimManager public draftClaimManager;
    mapping(address => bool) public approvedPublishReceivers;
    mapping(uint256 => bytes32) public draftIdByMarketId;

    /// @notice Mapping for used external IDs.
    mapping(bytes32 => bool) public usedExternalIds;
    /// @notice Mapping for market metadata.
    mapping(uint256 => MarketMetadata) public marketMetadata;

    uint8 public constant MARKET_TYPE_BINARY = 0;
    uint8 public constant MARKET_TYPE_CATEGORICAL = 1;
    uint8 public constant MARKET_TYPE_TIMELINE = 2;

    /// @notice Constructor for the MarketFactory.
    /// @param forwarderAddress The address of the forwarder.
    /// @param predictionMarketAddress The address of the prediction market.
    constructor(address forwarderAddress, address predictionMarketAddress) ReceiverTemplate(forwarderAddress) {
        if (predictionMarketAddress == address(0)) revert InvalidMarketAddress();
        PREDICTION_MARKET = IPredictionMarket(predictionMarketAddress);
    }

    /// @notice Update question length bounds.
    function setQuestionBounds(uint256 minLength, uint256 maxLength) external onlyOwner {
        minQuestionLength = minLength;
        maxQuestionLength = maxLength;
    }

    /// @notice Set MarketRegistry for curated createFromDraft path.
    function setMarketRegistry(address registry) external onlyOwner {
        marketRegistry = IMarketRegistryCreate(registry);
    }

    /// @notice Set MarketDraftBoard for curated createFromDraft path.
    function setDraftBoard(address board) external onlyOwner {
        draftBoard = MarketDraftBoard(board);
    }

    /// @notice Set DraftClaimManager for liquidity vault binding.
    function setDraftClaimManager(address claimManager) external onlyOwner {
        draftClaimManager = DraftClaimManager(claimManager);
    }

    /// @notice Approve or revoke a publish receiver (e.g. CREPublishReceiver).
    function setPublishReceiverApproved(address receiver, bool approved) external onlyOwner {
        approvedPublishReceivers[receiver] = approved;
    }

    /// @notice Create market from claimed draft. Uses draft times exactly, binds liquidity vault if claimAndSeed used.
    function createFromDraft(
        bytes32 draftId,
        address creator,
        DraftPublishParams calldata params
    ) external returns (uint256 marketId) {
        if (!approvedPublishReceivers[msg.sender]) revert UnauthorizedPublishReceiver();
        if (address(marketRegistry) == address(0)) revert CuratedPathNotConfigured();
        if (address(draftBoard) == address(0)) revert CuratedPathNotConfigured();

        MarketDraftBoard.Draft memory d = draftBoard.getDraft(draftId);
        // Curated draft times are source of truth; payload may repeat values but cannot override.
        if (params.tradingOpen != 0 && params.tradingOpen != d.tradingOpen) revert DraftTimeMismatch();
        if (params.tradingClose != 0 && params.tradingClose != d.tradingClose) revert DraftTimeMismatch();
        if (params.resolveTime != 0 && params.resolveTime != d.resolveTime) revert DraftTimeMismatch();
        uint48 tradingOpen = d.tradingOpen;
        uint48 tradingClose = d.tradingClose;
        uint48 resolveTime = d.resolveTime;

        address liquidityVault = address(draftClaimManager) != address(0)
            ? draftClaimManager.getLiquidityVault(draftId)
            : address(0);

        // Curated publish requires claimAndSeed (SEEDED claim type). Legacy claimDraft cannot publish.
        if (address(draftClaimManager) != address(0)
            && draftClaimManager.claimTypeByDraftId(draftId) != DraftClaimManager.ClaimType.SEEDED) {
            revert SeededClaimRequired();
        }

        // For seeded curated markets, a seeded claim is mandatory before publish.
        if (d.minSeed > 0 && liquidityVault == address(0)) revert SeededClaimRequired();

        address settlementAsset = d.settlementAsset;
        if (liquidityVault != address(0)) {
            address vaultAsset = ILiquidityVault4626(liquidityVault).asset();
            if (settlementAsset == address(0)) {
                settlementAsset = vaultAsset;
            } else if (vaultAsset != settlementAsset) {
                revert InvalidLiquidityVaultAsset();
            }
        }

        if (params.marketType == MARKET_TYPE_BINARY) {
            marketId = marketRegistry.createMarketForWithFullParams(
                params.question,
                creator,
                tradingOpen,
                tradingClose,
                resolveTime,
                settlementAsset
            );
        } else if (params.marketType == MARKET_TYPE_CATEGORICAL) {
            if (params.outcomes.length < 2) revert InvalidOutcomeCount();
            marketId = marketRegistry.createCategoricalMarketForWithFullParams(
                params.question,
                params.outcomes,
                creator,
                tradingOpen,
                tradingClose,
                resolveTime,
                settlementAsset
            );
        } else if (params.marketType == MARKET_TYPE_TIMELINE) {
            if (params.timelineWindows.length < 2) revert InvalidOutcomeCount();
            for (uint256 i = 1; i < params.timelineWindows.length; i++) {
                if (params.timelineWindows[i] <= params.timelineWindows[i - 1]) revert InvalidTimelineWindows();
            }
            marketId = marketRegistry.createTimelineMarketForWithFullParams(
                params.question,
                params.timelineWindows,
                creator,
                tradingOpen,
                tradingClose,
                resolveTime,
                settlementAsset
            );
        } else {
            revert InvalidMarketType();
        }

        if (liquidityVault != address(0)) {
            marketRegistry.setLiquidityVault(marketId, liquidityVault);
        }

        draftBoard.markPublished(draftId, marketId);
        draftIdByMarketId[marketId] = draftId;
    }

    /// @notice Process the report from the CRE.
    /// @param report The report from the CRE.
    function _processReport(bytes calldata report) internal override {
        if (report.length > 0 && report[0] == 0x02) {
            MarketInputV2 memory inputV2 = abi.decode(report[1:], (MarketInputV2));
            _validateInputV2(inputV2);
            usedExternalIds[inputV2.externalId] = true;

            // create the typed market
            uint256 marketIdV2 = _createTypedMarket(inputV2);
            // store the market metadata
            marketMetadata[marketIdV2] = MarketMetadata({
                requestedBy: inputV2.requestedBy,
                resolveTime: inputV2.resolveTime,
                category: inputV2.category,
                source: inputV2.source,
                externalId: inputV2.externalId,
                marketType: inputV2.marketType,
                outcomesCount: _outcomesCount(inputV2)
            });

            // emit the market spawned event
            emit MarketSpawned(
                marketIdV2,
                inputV2.requestedBy,
                inputV2.question,
                inputV2.resolveTime,
                inputV2.category,
                inputV2.source,
                inputV2.externalId
            );

            // emit the market spawned typed event
            emit MarketSpawnedTyped(
                marketIdV2,
                inputV2.requestedBy,
                inputV2.marketType,
                _outcomesCount(inputV2),
                inputV2.externalId
            );
            return;
        }

        // create the binary market
        MarketInput memory input = abi.decode(report, (MarketInput));
        _validateInput(input);
        usedExternalIds[input.externalId] = true;

        // create the binary market (pass resolveTime as expiry for MarketRegistry compatibility)
        uint256 marketId =
            PREDICTION_MARKET.createMarketForWithExpiry(input.question, input.requestedBy, input.resolveTime);
        // store the market metadata
        marketMetadata[marketId] = MarketMetadata({
            requestedBy: input.requestedBy,
            resolveTime: input.resolveTime,
            category: input.category,
            source: input.source,
            externalId: input.externalId,
            marketType: MARKET_TYPE_BINARY,
            outcomesCount: 2
        });

        // emit the market spawned event
        emit MarketSpawned(
            marketId,
            input.requestedBy,
            input.question,
            input.resolveTime,
            input.category,
            input.source,
            input.externalId
        );
    }

    /// @notice Validate the input for a binary market.
    /// @param input The input for a binary market.
    function _validateInput(MarketInput memory input) internal view {
        if (input.requestedBy == address(0)) revert InvalidRequestedBy();
        uint256 questionLength = bytes(input.question).length;
        if (questionLength < minQuestionLength || questionLength > maxQuestionLength) revert InvalidQuestion();
        if (input.resolveTime <= block.timestamp) revert ResolveTimeInPast();
        if (usedExternalIds[input.externalId]) revert DuplicateExternalId();

        // validate the signature
        if (input.signature.length > 0) {
            bytes32 digest = keccak256(
                abi.encodePacked(
                    address(this),
                    input.requestedBy,
                    input.question,
                    input.resolveTime,
                    input.category,
                    input.source,
                    input.externalId
                )
            ).toEthSignedMessageHash(); /// @notice create the digest for the signature

            // recover the signer from the signature
            address signer = ECDSA.recover(digest, input.signature);
            if (signer != input.requestedBy) revert InvalidSignature(); /// @notice if the signer is not the requested by, revert
        }
    }

    /// @notice Validate the input for a typed market (categorical and timeline).
    /// @param input The input for a typed market.
    function _validateInputV2(MarketInputV2 memory input) internal view {
        if (input.requestedBy == address(0)) revert InvalidRequestedBy();
        uint256 questionLength = bytes(input.question).length;
        if (questionLength < minQuestionLength || questionLength > maxQuestionLength) revert InvalidQuestion();
        if (input.resolveTime <= block.timestamp) revert ResolveTimeInPast();
        if (usedExternalIds[input.externalId]) revert DuplicateExternalId();

        // validate the market type
        if (input.marketType == MARKET_TYPE_CATEGORICAL) {
            if (input.outcomes.length < 2) revert InvalidOutcomeCount();
        // validate the timeline windows
        } else if (input.marketType == MARKET_TYPE_TIMELINE) {
            if (input.timelineWindows.length < 2) revert InvalidOutcomeCount();
            // validate the timeline windows are in ascending order which will be used for the payout calculation
            for (uint256 i = 1; i < input.timelineWindows.length; i++) {
                // if the timeline windows are not in ascending order, revert
                if (input.timelineWindows[i] <= input.timelineWindows[i - 1]) revert InvalidTimelineWindows();
            }
        } else if (input.marketType != MARKET_TYPE_BINARY) {
            // if the market type is not binary, categorical, or timeline, revert
            revert InvalidMarketType();
        }

        if (input.signature.length > 0) {
            // forge-lint: disable-next-line(asm-keccak256)
            bytes32 outcomesHash = keccak256(abi.encode(input.outcomes));
            // forge-lint: disable-next-line(asm-keccak256)
            bytes32 windowsHash = keccak256(abi.encode(input.timelineWindows));
            bytes32 digest = keccak256(
                abi.encodePacked(
                    address(this),
                    input.requestedBy,
                    input.question,
                    input.resolveTime,
                    input.category,
                    input.source,
                    input.externalId,
                    input.marketType,
                    outcomesHash,
                    windowsHash
                )
            ).toEthSignedMessageHash();

            address signer = ECDSA.recover(digest, input.signature);
            if (signer != input.requestedBy) revert InvalidSignature();
        }
    }

    /// @notice Create a typed market (categorical or timeline).
    /// @param input The input for a typed market.
    /// @return The ID of the newly created market.
    function _createTypedMarket(MarketInputV2 memory input) internal returns (uint256) {
        uint48 expiry = input.resolveTime;
        // check if the market is binary
        if (input.marketType == MARKET_TYPE_BINARY) {
            return PREDICTION_MARKET.createMarketForWithExpiry(input.question, input.requestedBy, expiry);
        }
        // check if the market is categorical
        if (input.marketType == MARKET_TYPE_CATEGORICAL) {
            return PREDICTION_MARKET.createCategoricalMarketForWithExpiry(
                input.question, input.outcomes, input.requestedBy, expiry
            );
        }
        // check if the market is timeline
        if (input.marketType == MARKET_TYPE_TIMELINE) {
            return PREDICTION_MARKET.createTimelineMarketForWithExpiry(
                input.question, input.timelineWindows, input.requestedBy, expiry
            );
        }
        revert InvalidMarketType();
    }

    /// @notice Get the number of outcomes for a typed market.
    /// @param input The input for a typed market.
    /// @return The number of outcomes for the market.
    function _outcomesCount(MarketInputV2 memory input) internal pure returns (uint8) {
        // check if the market is timeline
        if (input.marketType == MARKET_TYPE_TIMELINE) {
            // return the number of timeline windows
            return uint8(input.timelineWindows.length);
        }
        // check if the market is categorical
        if (input.marketType == MARKET_TYPE_CATEGORICAL) {
            return uint8(input.outcomes.length);
        }
        return 2;
    }
}
