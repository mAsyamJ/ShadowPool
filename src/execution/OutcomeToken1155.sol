// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Arrays} from "@openzeppelin/contracts/utils/Arrays.sol";
import {IOutcomeToken1155} from "../interfaces/IOutcomeToken1155.sol";
import {IMarketRegistry} from "../interfaces/IMarketRegistry.sol";
import {Errors} from "../utils/Errors.sol";

/// @title OutcomeToken1155
/// @notice ERC-1155 outcome tokens for RetroPick markets. Transfer-locked until market resolved.
/// @dev Token ID = (marketId << 32) | outcomeIndex. Only ChannelSettlement mints/burns during trading.
contract OutcomeToken1155 is ERC1155, Ownable, IOutcomeToken1155 {
    using Arrays for uint256[];
    using Arrays for address[];

    address public channelSettlement;
    address public marketRegistry;

    modifier onlyChannelSettlement() {
        if (msg.sender != channelSettlement) revert Errors.Unauthorized();
        _;
    }

    modifier onlyMarketRegistry() {
        if (msg.sender != marketRegistry) revert Errors.Unauthorized();
        _;
    }

    constructor(string memory uri_) ERC1155(uri_) Ownable(msg.sender) {}

    function id(uint256 marketId, uint32 outcomeIndex) external pure returns (uint256) {
        return (marketId << 32) | uint256(outcomeIndex);
    }

    function setChannelSettlement(address cs) external onlyOwner {
        if (cs == address(0)) revert Errors.InvalidAddress();
        channelSettlement = cs;
    }

    function setMarketRegistry(address mr) external onlyOwner {
        if (mr == address(0)) revert Errors.InvalidAddress();
        marketRegistry = mr;
    }

    function mint(address to, uint256 marketId, uint32 outcomeIndex, uint256 amount) external onlyChannelSettlement {
        uint256 tokenId = (marketId << 32) | uint256(outcomeIndex);
        _mint(to, tokenId, amount, "");
    }

    function burn(address from, uint256 marketId, uint32 outcomeIndex, uint256 amount) external onlyChannelSettlement {
        uint256 tokenId = (marketId << 32) | uint256(outcomeIndex);
        _burn(from, tokenId, amount);
    }

    function burnForRedeem(address from, uint256 marketId, uint32 outcomeIndex, uint256 amount) external onlyMarketRegistry {
        uint256 tokenId = (marketId << 32) | uint256(outcomeIndex);
        _burn(from, tokenId, amount);
    }

    /// @dev Override to enforce transfer lock: user-to-user transfers only allowed when market resolved.
    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal virtual override {
        if (from != address(0) && to != address(0)) {
            IMarketRegistry mr = IMarketRegistry(marketRegistry);
            if (address(mr) != address(0)) {
                for (uint256 i = 0; i < ids.length; ++i) {
                    uint256 tokenId = ids.unsafeMemoryAccess(i);
                    uint256 marketId = tokenId >> 32;
                    if (mr.status(marketId) != IMarketRegistry.Status.Resolved) {
                        revert Errors.TransferLocked();
                    }
                }
            }
        }
        super._update(from, to, ids, values);
    }
}
