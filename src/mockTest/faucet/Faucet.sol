// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {AccessManager} from "../core/AccessManager.sol";
import {IERC20Minimal} from "../interfaces/IERC20Minimal.sol";
import {SafeTransferLib} from "../libs/SafeTransferLib.sol";
import {Errors} from "../libs/Errors.sol";

/// @notice Onchain faucet for test stablecoins (rate-limited per user per token).
contract Faucet is AccessManager {
    using SafeTransferLib for IERC20Minimal;

    struct TokenConfig {
        bool enabled;
        uint96 amountPerClaim;
        uint32 cooldownSecs;
    }

    mapping(address => TokenConfig) public tokenConfig;
    mapping(address => mapping(address => uint256)) public lastClaimAt;

    event TokenConfigured(address indexed token, bool enabled, uint96 amountPerClaim, uint32 cooldownSecs);
    event Claimed(address indexed user, address indexed token, uint96 amount);

    constructor(address owner) AccessManager(owner) {}

    function setToken(
        address token,
        bool enabled,
        uint96 amountPerClaim,
        uint32 cooldownSecs
    ) external onlyOwner {
        if (token == address(0)) revert Errors.InvalidAddress();
        if (amountPerClaim == 0 || cooldownSecs == 0) revert Errors.InvalidAmount();

        tokenConfig[token] = TokenConfig({
            enabled: enabled,
            amountPerClaim: amountPerClaim,
            cooldownSecs: cooldownSecs
        });

        emit TokenConfigured(token, enabled, amountPerClaim, cooldownSecs);
    }

    function canClaim(address user, address token) external view returns (bool) {
        TokenConfig memory cfg = tokenConfig[token];
        if (!cfg.enabled) return false;
        return block.timestamp >= lastClaimAt[user][token] + cfg.cooldownSecs;
    }

    function claim(address token) external {
        TokenConfig memory cfg = tokenConfig[token];
        if (!cfg.enabled) revert Errors.InvalidState();
        if (block.timestamp < lastClaimAt[msg.sender][token] + cfg.cooldownSecs) revert Errors.InvalidState();

        lastClaimAt[msg.sender][token] = block.timestamp;

        IERC20Minimal asset = IERC20Minimal(token);
        if (asset.balanceOf(address(this)) < cfg.amountPerClaim) revert Errors.InvalidAmount();

        asset.safeTransfer(msg.sender, cfg.amountPerClaim);
        emit Claimed(msg.sender, token, cfg.amountPerClaim);
    }
}