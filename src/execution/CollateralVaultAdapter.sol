// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ICollateralVault} from "../interfaces/ICollateralVault.sol";
import {IMultiAssetVault} from "../interfaces/IMultiAssetVault.sol";

/// @title CollateralVaultAdapter
/// @notice Wraps ICollateralVault to implement IMultiAssetVault. Fixes asset = token().
contract CollateralVaultAdapter is IMultiAssetVault {
    ICollateralVault public immutable VAULT;

    error InvalidAsset();

    constructor(address vault_) {
        VAULT = ICollateralVault(vault_);
    }

    function _requireToken(address asset) internal view {
        if (asset != address(0) && asset != VAULT.token()) revert InvalidAsset();
    }

    function deposit(address asset, uint256 amount) external override {
        _requireToken(asset);
        VAULT.deposit(amount);
    }

    function withdraw(address asset, uint256 amount) external override {
        _requireToken(asset);
        VAULT.withdraw(amount);
    }

    function freeBalance(address user, address asset) external view override returns (uint256) {
        _requireToken(asset);
        return VAULT.freeBalance(user);
    }

    function reservedBalance(address user, address asset) external view override returns (uint256) {
        _requireToken(asset);
        return VAULT.reservedBalance(user);
    }

    function availableBalance(address user, address asset) external view override returns (uint256) {
        _requireToken(asset);
        return VAULT.availableBalance(user);
    }

    function reserve(address user, address asset, uint256 amount) external override {
        _requireToken(asset);
        VAULT.reserve(user, amount);
    }

    function release(address user, address asset, uint256 amount) external override {
        _requireToken(asset);
        VAULT.release(user, amount);
    }

    function lockedBalance(address user, address asset, uint256 marketId, bytes32 sessionId)
        external
        view
        override
        returns (uint256)
    {
        _requireToken(asset);
        return VAULT.lockedBalance(user, marketId, sessionId);
    }

    function lock(address user, address asset, uint256 marketId, bytes32 sessionId, uint256 amount) external override {
        _requireToken(asset);
        VAULT.lock(user, marketId, sessionId, amount);
    }

    function unlock(address user, address asset, uint256 marketId, bytes32 sessionId, uint256 amount) external override {
        _requireToken(asset);
        VAULT.unlock(user, marketId, sessionId, amount);
    }

    function redeemPayout(address to, address asset, uint256 amount) external override {
        _requireToken(asset);
        VAULT.redeemPayout(to, amount);
    }

    function applyCashDeltas(
        address asset,
        uint256 marketId,
        bytes32 sessionId,
        address[] calldata users,
        int128[] calldata cashDeltas
    ) external override {
        _requireToken(asset);
        VAULT.applyCashDeltas(marketId, sessionId, users, cashDeltas);
    }

    function transferToFeeCollector(address to, address asset, uint256 amount) external override {
        _requireToken(asset);
        VAULT.transferToFeeCollector(to, amount);
    }

    function transferAsset(address to, address asset, uint256 amount) external override {
        _requireToken(asset);
        VAULT.transferToFeeCollector(to, amount);
    }

    /// @notice Returns the single token for this adapter.
    function token() external view returns (address) {
        return VAULT.token();
    }
}
