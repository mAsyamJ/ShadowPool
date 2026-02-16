// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title FeeManager
/// @notice Protocol fee policy with hard caps; computes fee on positive PnL; supports protocol/lp/creator split.
contract FeeManager is Ownable {
    uint16 public protocolFeeBps;
    uint16 public lpFeeShareBps; // share of total fee to LPs (0-10000)
    uint16 public creatorFeeShareBps; // share of total fee to creator (0-10000)
    uint16 public constant MAX_PROTOCOL_FEE_BPS = 200; // 2% max
    uint16 public constant BPS_DENOMINATOR = 10_000;

    event ProtocolFeeBpsUpdated(uint16 previous, uint16 current);
    event LpFeeShareBpsUpdated(uint16 previous, uint16 current);
    event CreatorFeeShareBpsUpdated(uint16 previous, uint16 current);

    constructor(uint16 protocolFeeBps_) Ownable(msg.sender) {
        if (protocolFeeBps_ > MAX_PROTOCOL_FEE_BPS) revert FeeExceedsCap();
        protocolFeeBps = protocolFeeBps_;
    }

    error FeeExceedsCap();
    error InvalidFeeShare();

    /// @notice Update protocol fee; cannot exceed MAX_PROTOCOL_FEE_BPS.
    function setProtocolFeeBps(uint16 bps) external onlyOwner {
        if (bps > MAX_PROTOCOL_FEE_BPS) revert FeeExceedsCap();
        uint16 previous = protocolFeeBps;
        protocolFeeBps = bps;
        emit ProtocolFeeBpsUpdated(previous, bps);
    }

    /// @notice Set LP fee share (of total fee bucket). lpShareBps + creatorShareBps must be <= 10000.
    function setLpFeeShareBps(uint16 bps) external onlyOwner {
        if (bps + creatorFeeShareBps > BPS_DENOMINATOR) revert InvalidFeeShare();
        uint16 previous = lpFeeShareBps;
        lpFeeShareBps = bps;
        emit LpFeeShareBpsUpdated(previous, bps);
    }

    /// @notice Set creator fee share (of total fee bucket). lpShareBps + creatorShareBps must be <= 10000.
    function setCreatorFeeShareBps(uint16 bps) external onlyOwner {
        if (lpFeeShareBps + bps > BPS_DENOMINATOR) revert InvalidFeeShare();
        uint16 previous = creatorFeeShareBps;
        creatorFeeShareBps = bps;
        emit CreatorFeeShareBpsUpdated(previous, bps);
    }

    /// @notice Compute fee on positive PnL; returns (fee in uint256, netDelta as int128).
    /// @param pnlDelta Cash delta (positive = profit). Fee only applied when > 0.
    function computeFee(int128 pnlDelta) external view returns (uint256 fee, int128 netDelta) {
        if (pnlDelta <= 0) return (0, pnlDelta);
        uint256 profit = uint128(pnlDelta);
        fee = (profit * protocolFeeBps) / BPS_DENOMINATOR;
        netDelta = int128(int256(profit - fee));
    }

    /// @notice Compute fee split for positive PnL. Returns protocol, lp, creator fees and net delta.
    function computeSplit(int128 pnlDelta)
        external
        view
        returns (uint256 protocolFee, uint256 lpFee, uint256 creatorFee, int128 netDelta)
    {
        if (pnlDelta <= 0) return (0, 0, 0, pnlDelta);
        uint256 profit = uint128(pnlDelta);
        uint256 totalFee = (profit * protocolFeeBps) / BPS_DENOMINATOR;
        protocolFee = (totalFee * (BPS_DENOMINATOR - lpFeeShareBps - creatorFeeShareBps)) / BPS_DENOMINATOR;
        lpFee = (totalFee * lpFeeShareBps) / BPS_DENOMINATOR;
        creatorFee = (totalFee * creatorFeeShareBps) / BPS_DENOMINATOR;
        netDelta = int128(int256(profit - totalFee));
    }
}
