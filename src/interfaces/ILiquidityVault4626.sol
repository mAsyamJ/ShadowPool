// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @title ILiquidityVault4626
/// @notice Settlement calls payToTradingLedger when net trader PnL is positive.
interface ILiquidityVault4626 {
    function asset() external view returns (address);
    function totalSupply() external view returns (uint256);
    function payToTradingLedger(address to, uint256 amount) external;
}
