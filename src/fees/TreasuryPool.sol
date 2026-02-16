// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title TreasuryPool
/// @notice Protocol treasury; receives sweeps from FeePool; strict spend authorization.
contract TreasuryPool is Ownable {
    using SafeERC20 for IERC20;

    constructor() Ownable(msg.sender) {}

    event ReceivedSweep(address indexed asset, uint256 amount);
    event Spent(address indexed asset, address indexed to, uint256 amount, string reason);

    error InvalidAddress();
    error InsufficientBalance();

    /// @notice Called by FeePool when sweeping.
    function receiveSweep(address asset, uint256 amount) external {
        emit ReceivedSweep(asset, amount);
    }

    /// @notice Spend treasury funds (governance/owner only).
    function spend(address asset, address to, uint256 amount, string calldata reason) external onlyOwner {
        if (to == address(0)) revert InvalidAddress();
        if (amount == 0) return;
        IERC20(asset).safeTransfer(to, amount);
        emit Spent(asset, to, amount, reason);
    }

    function balanceOf(address asset) external view returns (uint256) {
        return IERC20(asset).balanceOf(address(this));
    }
}
