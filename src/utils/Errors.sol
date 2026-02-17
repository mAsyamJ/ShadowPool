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
}
