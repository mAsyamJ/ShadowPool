// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @title IMultiAssetVault
/// @notice Multi-asset custody: per-asset balances, deposit/withdraw, apply deltas.
interface IMultiAssetVault {
    function deposit(address asset, uint256 amount) external;
    function withdraw(address asset, uint256 amount) external;

    function freeBalance(address user, address asset) external view returns (uint256);
    function reservedBalance(address user, address asset) external view returns (uint256);
    function availableBalance(address user, address asset) external view returns (uint256);
    function lockedBalance(address user, address asset, uint256 marketId, bytes32 sessionId) external view returns (uint256);

    function reserve(address user, address asset, uint256 amount) external;
    function release(address user, address asset, uint256 amount) external;

    function lock(address user, address asset, uint256 marketId, bytes32 sessionId, uint256 amount) external;
    function unlock(address user, address asset, uint256 marketId, bytes32 sessionId, uint256 amount) external;

    /// @notice Payout for market redemption (only MarketRegistry).
    function redeemPayout(address to, address asset, uint256 amount) external;

    /// @notice Apply signed net cash deltas (only ChannelSettlement).
    function applyCashDeltas(
        address asset,
        uint256 marketId,
        bytes32 sessionId,
        address[] calldata users,
        int128[] calldata cashDeltas
    ) external;

    /// @notice Transfer tokens to fee collector; only ChannelSettlement.
    function transferToFeeCollector(address to, address asset, uint256 amount) external;

    /// @notice Transfer asset to any address (fee routing, net PnL). Only ChannelSettlement.
    function transferAsset(address to, address asset, uint256 amount) external;
}
