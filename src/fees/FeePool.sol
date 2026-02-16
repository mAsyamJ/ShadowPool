// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title FeePool
/// @notice Receives protocol fees; can sweep to TreasuryPool.
interface ITreasuryPool {
    function receiveSweep(address asset, uint256 amount) external;
}

/// @title FeePool
/// @notice Receives and holds fees per asset; sweepable to TreasuryPool.
contract FeePool is Ownable {
    using SafeERC20 for IERC20;

    address public feeCollector;
    address public treasuryPool;

    event FeeCollected(address indexed asset, uint256 amount, uint256 indexed marketId, bytes32 indexed sessionId);
    event SweptToTreasury(address indexed asset, uint256 amount);
    event FeeCollectorUpdated(address indexed previous, address indexed current);
    event TreasuryPoolUpdated(address indexed previous, address indexed current);

    error InvalidAddress();
    error OnlyFeeCollector();
    error TreasuryNotSet();

    constructor() Ownable(msg.sender) {}

    function setFeeCollector(address collector) external onlyOwner {
        if (collector == address(0)) revert InvalidAddress();
        address previous = feeCollector;
        feeCollector = collector;
        emit FeeCollectorUpdated(previous, collector);
    }

    function setTreasuryPool(address treasury) external onlyOwner {
        address previous = treasuryPool;
        treasuryPool = treasury;
        emit TreasuryPoolUpdated(previous, treasury);
    }

    /// @notice Record fee received (tokens transferred separately via vault.transferToFeeCollector).
    function recordFeeCollected(address asset, uint256 amount, uint256 marketId, bytes32 sessionId) external {
        if (msg.sender != feeCollector) revert OnlyFeeCollector();
        if (amount == 0) return;
        emit FeeCollected(asset, amount, marketId, sessionId);
    }

    /// @notice Sweep collected fees to TreasuryPool.
    function sweepToTreasury(address asset, uint256 amount) external onlyOwner {
        if (treasuryPool == address(0)) revert TreasuryNotSet();
        if (amount == 0) return;
        IERC20(asset).safeTransfer(treasuryPool, amount);
        ITreasuryPool(treasuryPool).receiveSweep(asset, amount);
        emit SweptToTreasury(asset, amount);
    }

    function balanceOf(address asset) external view returns (uint256) {
        return IERC20(asset).balanceOf(address(this));
    }
}
