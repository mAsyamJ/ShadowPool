// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title FeeManager
/// @notice Protocol fee policy with hard caps; computes fee on positive PnL.
contract FeeManager is Ownable {
    uint16 public protocolFeeBps;
    uint16 public constant MAX_PROTOCOL_FEE_BPS = 200; // 2% max

    event ProtocolFeeBpsUpdated(uint16 previous, uint16 current);

    constructor(uint16 protocolFeeBps_) Ownable(msg.sender) {
        if (protocolFeeBps_ > MAX_PROTOCOL_FEE_BPS) revert FeeExceedsCap();
        protocolFeeBps = protocolFeeBps_;
    }

    error FeeExceedsCap();

    /// @notice Update protocol fee; cannot exceed MAX_PROTOCOL_FEE_BPS.
    function setProtocolFeeBps(uint16 bps) external onlyOwner {
        if (bps > MAX_PROTOCOL_FEE_BPS) revert FeeExceedsCap();
        uint16 previous = protocolFeeBps;
        protocolFeeBps = bps;
        emit ProtocolFeeBpsUpdated(previous, bps);
    }

    /// @notice Compute fee on positive PnL; returns (fee in uint256, netDelta as int128).
    /// @param pnlDelta Cash delta (positive = profit). Fee only applied when > 0.
    function computeFee(int128 pnlDelta) external view returns (uint256 fee, int128 netDelta) {
        if (pnlDelta <= 0) return (0, pnlDelta);
        uint256 profit = uint128(pnlDelta);
        fee = (profit * protocolFeeBps) / 10_000;
        netDelta = int128(int256(profit - fee));
    }
}
