// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {MarketRegistry} from "../core/MarketRegistry.sol";

/// @title RelayerTestMarketFactory
/// @notice Minimal market factory for relayer integration tests. Creates a single binary market.
/// @dev Set as marketRegistry.marketFactory; call createTestMarket to seed.
contract RelayerTestMarketFactory {
    MarketRegistry public marketRegistry;

    constructor(address marketRegistry_) {
        marketRegistry = MarketRegistry(marketRegistry_);
    }

    /// @notice Create a binary market for relayer E2E tests.
    function createTestMarket(
        string memory question,
        address creator,
        uint48 expiry,
        address settlementAsset
    ) external returns (uint256 marketId) {
        return marketRegistry.createMarketForWithExpiryAndAsset(question, creator, expiry, settlementAsset);
    }
}
