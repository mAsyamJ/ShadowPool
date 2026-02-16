// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ICollateralVault} from "../interfaces/ICollateralVault.sol";
import {IMultiAssetVault} from "../interfaces/IMultiAssetVault.sol";
import {Errors} from "../utils/Errors.sol";

/// @title CollateralVaultAdapter
/// @notice Wraps ICollateralVault to implement IMultiAssetVault. Fixes asset = token().
contract CollateralVaultAdapter is IMultiAssetVault {
    ICollateralVault public immutable vault;

    error InvalidAsset();

    constructor(address vault_) {
        vault = ICollateralVault(vault_);
    }

    function _requireToken(address asset) internal view {
        if (asset != address(0) && asset != vault.token()) revert InvalidAsset();
    }

    function deposit(address asset, uint256 amount) external override {
        _requireToken(asset);
        vault.deposit(amount);
    }

    function withdraw(address asset, uint256 amount) external override {
        _requireToken(asset);
        vault.withdraw(amount);
    }

    function freeBalance(address user, address asset) external view override returns (uint256) {
        _requireToken(asset);
        return vault.freeBalance(user);
    }

    function lockedBalance(address user, address asset, uint256 marketId, bytes32 sessionId)
        external
        view
        override
        returns (uint256)
    {
        _requireToken(asset);
        return vault.lockedBalance(user, marketId, sessionId);
    }

    function lock(address user, address asset, uint256 marketId, bytes32 sessionId, uint256 amount) external override {
        _requireToken(asset);
        vault.lock(user, marketId, sessionId, amount);
    }

    function unlock(address user, address asset, uint256 marketId, bytes32 sessionId, uint256 amount) external override {
        _requireToken(asset);
        vault.unlock(user, marketId, sessionId, amount);
    }

    function redeemPayout(address to, address asset, uint256 amount) external override {
        _requireToken(asset);
        vault.redeemPayout(to, amount);
    }

    function applyCashDeltas(
        address asset,
        uint256 marketId,
        bytes32 sessionId,
        address[] calldata users,
        int128[] calldata cashDeltas
    ) external override {
        _requireToken(asset);
        vault.applyCashDeltas(marketId, sessionId, users, cashDeltas);
    }

    function transferToFeeCollector(address to, address asset, uint256 amount) external override {
        _requireToken(asset);
        vault.transferToFeeCollector(to, amount);
    }

    function transferAsset(address to, address asset, uint256 amount) external override {
        _requireToken(asset);
        vault.transferToFeeCollector(to, amount);
    }

    /// @notice Returns the single token for this adapter.
    function token() external view returns (address) {
        return vault.token();
    }
}
