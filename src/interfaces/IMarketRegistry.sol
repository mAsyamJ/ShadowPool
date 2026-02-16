// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface IMarketRegistry {
    enum MarketType {
        Binary,
        Categorical,
        Timeline
    }
    enum Status {
        Draft,
        Open,
        Frozen,
        Resolved,
        Closed
    }

    function marketType(uint256 marketId) external view returns (MarketType);
    function status(uint256 marketId) external view returns (Status);
    function getTradingClose(uint256 marketId) external view returns (uint48);
    function getSettlementAsset(uint256 marketId) external view returns (address);
    function resolve(uint256 marketId, uint32 winningOutcome, uint16 confidence) external;
    function redeem(uint256 marketId) external returns (uint256 payout);
}
