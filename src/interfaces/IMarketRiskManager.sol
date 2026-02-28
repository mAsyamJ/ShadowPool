// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface IMarketRiskManager {
    function setMaxLpPayout(uint256 marketId, uint256 cap) external;
    function maxLpPayout(uint256 marketId) external view returns (uint256);
    function reservedLpPayout(uint256 marketId) external view returns (uint256);

    function reserveLpPayout(uint256 marketId, uint256 amount) external;
}
