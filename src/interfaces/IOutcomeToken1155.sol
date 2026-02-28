// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IOutcomeToken1155 is IERC1155 {
    /// @notice Compute token ID from marketId and outcomeIndex.
    function id(uint256 marketId, uint32 outcomeIndex) external pure returns (uint256);

    /// @notice Mint outcome tokens (onlyChannelSettlement).
    function mint(address to, uint256 marketId, uint32 outcomeIndex, uint256 amount) external;

    /// @notice Burn outcome tokens (onlyChannelSettlement).
    function burn(address from, uint256 marketId, uint32 outcomeIndex, uint256 amount) external;

    /// @notice Burn for redeem (onlyMarketRegistry).
    function burnForRedeem(address from, uint256 marketId, uint32 outcomeIndex, uint256 amount) external;

    function setChannelSettlement(address cs) external;
    function setMarketRegistry(address mr) external;
}
