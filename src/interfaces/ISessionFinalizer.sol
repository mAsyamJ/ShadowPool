// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @title ISessionFinalizer is the interface for the session finalizer.
/// @notice Interface for the session finalizer.
interface ISessionFinalizer {
    /// @notice Finalize the session.
    /// @param payload The payload to finalize the session.
    function finalizeSession(bytes calldata payload) external;
}
