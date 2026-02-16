// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title LiquidityVault4626
/// @notice Per-market ERC-4626 vault for LP liquidity. LP fees donated to vault increase share price pro-rata.
/// Settlement uses payToTradingLedger when net trader PnL is positive (vault pays traders).
contract LiquidityVault4626 is ERC4626, Ownable {
    using SafeERC20 for IERC20;

    address public channelSettlement;

    event ChannelSettlementUpdated(address indexed previous, address indexed current);
    event PaidToTradingLedger(address indexed to, uint256 amount);

    error OnlyChannelSettlement();

    constructor(address underlyingAsset, address channelSettlement_)
        ERC20("Liquidity Vault Share", "LVS")
        ERC4626(IERC20(underlyingAsset))
        Ownable(msg.sender)
    {
        channelSettlement = channelSettlement_;
    }

    function setChannelSettlement(address settlement_) external onlyOwner {
        address previous = channelSettlement;
        channelSettlement = settlement_;
        emit ChannelSettlementUpdated(previous, settlement_);
    }

    /// @notice Pay assets to trading ledger when net trader PnL is positive (vault is counterparty).
    /// Only callable by ChannelSettlement.
    function payToTradingLedger(address to, uint256 amount) external {
        if (msg.sender != channelSettlement) revert OnlyChannelSettlement();
        if (to == address(0) || amount == 0) return;
        IERC20(asset()).safeTransfer(to, amount);
        emit PaidToTradingLedger(to, amount);
    }
}
