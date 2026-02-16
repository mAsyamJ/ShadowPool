// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {LiquidityVault4626} from "../execution/LiquidityVault4626.sol";

/// @title LiquidityVaultFactory
/// @notice Deploys per-draft/per-market LiquidityVault4626 instances.
contract LiquidityVaultFactory is Ownable {
    address public channelSettlement;

    mapping(bytes32 => address) public vaultByDraftId;

    event VaultCreated(bytes32 indexed draftId, address indexed vault, address asset);
    event ChannelSettlementUpdated(address indexed previous, address indexed current);

    constructor(address channelSettlement_) Ownable(msg.sender) {
        channelSettlement = channelSettlement_;
    }

    function setChannelSettlement(address settlement_) external onlyOwner {
        address previous = channelSettlement;
        channelSettlement = settlement_;
        emit ChannelSettlementUpdated(previous, settlement_);
    }

    /// @notice Create a liquidity vault for a draft. Idempotent per draftId. Callable by any address.
    function createVaultForDraft(bytes32 draftId, address asset) external returns (address vault) {
        vault = vaultByDraftId[draftId];
        if (vault != address(0)) return vault;

        LiquidityVault4626 v = new LiquidityVault4626(asset, channelSettlement);
        vault = address(v);
        vaultByDraftId[draftId] = vault;
        emit VaultCreated(draftId, vault, asset);
    }

    function getVaultForDraft(bytes32 draftId) external view returns (address) {
        return vaultByDraftId[draftId];
    }
}
