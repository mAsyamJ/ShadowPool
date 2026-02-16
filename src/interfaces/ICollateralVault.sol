// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface ICollateralVault {
    function token() external view returns (address);

    function deposit(uint256 amount) external;
    function withdraw(uint256 amount) external;

    function freeBalance(address user) external view returns (uint256);
    function lockedBalance(address user, uint256 marketId, bytes32 sessionId) external view returns (uint256);

    function lock(address user, uint256 marketId, bytes32 sessionId, uint256 amount) external;
    function unlock(address user, uint256 marketId, bytes32 sessionId, uint256 amount) external;

    /// @notice Payout for market redemption (only MarketRegistry).
    function redeemPayout(address to, uint256 amount) external;

    /// @notice Apply signed net cash deltas (only ChannelSettlement).
    function applyCashDeltas(
        uint256 marketId,
        bytes32 sessionId,
        address[] calldata users,
        int128[] calldata cashDeltas
    ) external;

    /// @notice Transfer tokens to fee collector; only ChannelSettlement.
    function transferToFeeCollector(address to, uint256 amount) external;
}
