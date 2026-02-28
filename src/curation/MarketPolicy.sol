// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MarketDraftBoard} from "./MarketDraftBoard.sol";

/// @title MarketPolicy
/// @notice Rules for allowed market types, resolve specs, min duration, max outcomes.
contract MarketPolicy is Ownable {
    uint8 public constant MARKET_TYPE_BINARY = 0;
    uint8 public constant MARKET_TYPE_CATEGORICAL = 1;
    uint8 public constant MARKET_TYPE_TIMELINE = 2;

    uint256 public allowedMarketTypes; // bitmap: bit 0=Binary, 1=Categorical, 2=Timeline
    mapping(bytes32 => bool) public allowedResolveSpecHashes;
    bool public resolveSpecAllowlistEnabled; // if false, any resolveSpecHash allowed
    uint48 public minDuration;
    uint48 public maxDuration;
    uint8 public maxOutcomes;
    uint256 public minCreatorSeed;
    uint256 public lpExposureMultiplier = 3; // cap = minSeed * multiplier

    event AllowedMarketTypesUpdated(uint256 previous, uint256 current);
    event ResolveSpecAllowlistUpdated(bytes32 indexed hash, bool allowed);
    event ResolveSpecAllowlistEnabledUpdated(bool enabled);
    event MinDurationUpdated(uint48 previous, uint48 current);
    event MaxDurationUpdated(uint48 previous, uint48 current);
    event MaxOutcomesUpdated(uint8 previous, uint8 current);
    event MinCreatorSeedUpdated(uint256 previous, uint256 current);
    event LpExposureMultiplierUpdated(uint256 previous, uint256 current);

    error InvalidMarketType();
    error DurationTooShort();
    error DurationTooLong();
    error TooManyOutcomes();
    error ResolveSpecNotAllowed();
    error SeedTooLow();

    constructor() Ownable(msg.sender) {
        allowedMarketTypes =
            (uint256(1) << MARKET_TYPE_BINARY) | (uint256(1) << MARKET_TYPE_CATEGORICAL) | (uint256(1) << MARKET_TYPE_TIMELINE);
        maxOutcomes = 64;
        maxDuration = 365 days;
    }

    function setAllowedMarketTypes(uint256 bitmap) external onlyOwner {
        uint256 previous = allowedMarketTypes;
        allowedMarketTypes = bitmap;
        emit AllowedMarketTypesUpdated(previous, bitmap);
    }

    function setResolveSpecAllowed(bytes32 hash, bool allowed) external onlyOwner {
        allowedResolveSpecHashes[hash] = allowed;
        emit ResolveSpecAllowlistUpdated(hash, allowed);
    }

    function setResolveSpecAllowlistEnabled(bool enabled) external onlyOwner {
        resolveSpecAllowlistEnabled = enabled;
        emit ResolveSpecAllowlistEnabledUpdated(enabled);
    }

    function setMinDuration(uint48 duration) external onlyOwner {
        uint48 previous = minDuration;
        minDuration = duration;
        emit MinDurationUpdated(previous, duration);
    }

    function setMaxDuration(uint48 duration) external onlyOwner {
        uint48 previous = maxDuration;
        maxDuration = duration;
        emit MaxDurationUpdated(previous, duration);
    }

    function setMaxOutcomes(uint8 max) external onlyOwner {
        uint8 previous = maxOutcomes;
        maxOutcomes = max;
        emit MaxOutcomesUpdated(previous, max);
    }

    function setMinCreatorSeed(uint256 minSeed) external onlyOwner {
        uint256 previous = minCreatorSeed;
        minCreatorSeed = minSeed;
        emit MinCreatorSeedUpdated(previous, minSeed);
    }

    function setLpExposureMultiplier(uint256 multiplier) external onlyOwner {
        uint256 previous = lpExposureMultiplier;
        lpExposureMultiplier = multiplier;
        emit LpExposureMultiplierUpdated(previous, multiplier);
    }

    /// @notice Validate a draft against policy. Reverts if invalid.
    function validateDraft(MarketDraftBoard.Draft memory draft) external view {
        _validateDraft(draft);
    }

    /// @notice Validate draft with explicit outcomes count (e.g. from publish params).
    function validateDraftWithOutcomesCount(
        MarketDraftBoard.Draft memory draft,
        uint8 outcomesCount
    ) external view {
        _validateDraft(draft);
        if (outcomesCount > maxOutcomes) revert TooManyOutcomes();
    }

    function _validateDraft(MarketDraftBoard.Draft memory draft) internal view {
        uint8 mt = uint8(draft.marketType);
        if (mt > MARKET_TYPE_TIMELINE) revert InvalidMarketType();
        if ((allowedMarketTypes & (uint256(1) << mt)) == 0) revert InvalidMarketType();

        if (minCreatorSeed != 0 && draft.minSeed < minCreatorSeed) revert SeedTooLow();

        if (resolveSpecAllowlistEnabled && draft.resolveSpecHash != bytes32(0)) {
            if (!allowedResolveSpecHashes[draft.resolveSpecHash]) revert ResolveSpecNotAllowed();
        }

        uint48 duration = draft.resolveTime > draft.tradingOpen
            ? draft.resolveTime - draft.tradingOpen
            : 0;
        if (minDuration != 0 && duration < minDuration) revert DurationTooShort();
        if (maxDuration != 0 && duration > maxDuration) revert DurationTooLong();
    }
}
