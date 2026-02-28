// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

library Errors {
    error NotAuthorized();
    error InvalidState();
    error InvalidAmount();
    error InvalidAddress();
    error DeadlineNotReached();
    error DeadlinePassed();
    error AlreadyFunded();
    error NotFunded();
    error NotPayer();
    error NotCreator();
    error SplitSumMismatch();
    error StrategyNotSet();
    error StrategyNotAllowed();
    error VenueNotAllowed();
    error SlippageExceeded();
    error QuoteExpired();
}