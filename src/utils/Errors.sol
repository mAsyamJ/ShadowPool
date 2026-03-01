// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

library Errors {
    error Unauthorized();
    error InvalidAddress();
    error InvalidAmount();
    error InvalidConfidence();
    error TransferFailed();

    // ChannelSettlement
    error TooManyDeltas();
    error TooManyUsers();
    error SigLenMismatch();
    error BadDeltasHash();
    error TooEarly();
    error TooLate();
    error BadOperatorSig();
    error BadUserSig();
    error NonceNotIncreasing();
    error NoPendingToChallenge();
    error WindowPassed();
    error ChallengeNotNewer();
    error NoPending();
    error ChallengeWindow();
    error DeltaUserNotSigned();
    error DuplicateUsers();
    error MarketDoesNotExist();
    error MarketAlreadyResolved();
    error CheckpointAfterTradingClose();
    error LiquidityVaultRequired();

    // Escrow: reserve/release
    error InsufficientAvailableBalance();
    error InsufficientReservedBalance();
    error CancelTooEarly();

    // V3: ERC1155 + Risk Manager
    error BadCashAccounting();
    error LpVaultInsolvent(uint256 need, uint256 have);
    error RiskCapExceeded();
    error TransferLocked();
}
