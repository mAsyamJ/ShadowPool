// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @title ShadowTypes
/// @notice Canonical data types for ShadowPool checkpoint-based settlement.
library ShadowTypes {
    /// @notice Signed checkpoint representing offchain state commitment.
    struct Checkpoint {
        uint256 marketId;
        bytes32 sessionId;
        uint64 nonce;
        uint64 validAfter;
        uint64 validBefore;
        uint48 lastTradeAt;  // Freeze boundary: must be <= market.tradingClose
        bytes32 stateHash;
        bytes32 deltasHash;
        bytes32 riskHash;
    }

    /// @notice Netted effect to apply onchain per user.
    /// sharesDelta updates ExecutionLedger; cashDelta updates CollateralVault.
    struct Delta {
        address user;
        uint32 outcomeIndex;
        int128 sharesDelta;
        int128 cashDelta;
    }
}
