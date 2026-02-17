// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IMultiAssetVault} from "../interfaces/IMultiAssetVault.sol";
import {Errors} from "../utils/Errors.sol";

/// @title MultiAssetVault
/// @notice Per-asset custody: deposit/withdraw, lock/unlock per session.
contract MultiAssetVault is IMultiAssetVault, Ownable {
    using SafeERC20 for IERC20;
    using SafeCast for int256;

    address public channelSettlement;
    address public marketRegistry;

    mapping(address asset => mapping(address user => uint256)) private _freeBalance;
    mapping(bytes32 => uint256) private _lockedBalance;

    event Deposited(address indexed user, address indexed asset, uint256 amount);
    event Withdrawn(address indexed user, address indexed asset, uint256 amount);
    event Locked(address indexed user, address indexed asset, uint256 marketId, bytes32 sessionId, uint256 amount);
    event Unlocked(address indexed user, address indexed asset, uint256 marketId, bytes32 sessionId, uint256 amount);
    event ChannelSettlementUpdated(address indexed previous, address indexed current);
    event MarketRegistryUpdated(address indexed previous, address indexed current);
    event CashDeltasApplied(address indexed asset, uint256 indexed marketId, bytes32 indexed sessionId, uint256 userCount);

    error OnlyChannelSettlement();
    error InsufficientFreeBalance();
    error InsufficientLockedBalance();
    error NegativeResult();
    error OnlyMarketRegistry();

    constructor(address channelSettlement_) Ownable(msg.sender) {
        channelSettlement = channelSettlement_;
    }

    function setMarketRegistry(address marketRegistry_) external onlyOwner {
        if (marketRegistry_ == address(0)) revert Errors.InvalidAddress();
        address previous = marketRegistry;
        marketRegistry = marketRegistry_;
        emit MarketRegistryUpdated(previous, marketRegistry_);
    }

    function setChannelSettlement(address channelSettlement_) external onlyOwner {
        if (channelSettlement_ == address(0)) revert Errors.InvalidAddress();
        address previous = channelSettlement;
        channelSettlement = channelSettlement_;
        emit ChannelSettlementUpdated(previous, channelSettlement_);
    }

    function deposit(address asset, uint256 amount) external override {
        if (asset == address(0) || amount == 0) revert Errors.InvalidAmount();
        _freeBalance[asset][msg.sender] += amount;
        IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);
        emit Deposited(msg.sender, asset, amount);
    }

    function withdraw(address asset, uint256 amount) external override {
        if (asset == address(0) || amount == 0) revert Errors.InvalidAmount();
        if (_freeBalance[asset][msg.sender] < amount) revert InsufficientFreeBalance();
        _freeBalance[asset][msg.sender] -= amount;
        IERC20(asset).safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, asset, amount);
    }

    function freeBalance(address user, address asset) external view override returns (uint256) {
        return _freeBalance[asset][user];
    }

    function lockedBalance(address user, address asset, uint256 marketId, bytes32 sessionId)
        external
        view
        override
        returns (uint256)
    {
        return _lockedBalance[_lockKey(asset, user, marketId, sessionId)];
    }

    function lock(address user, address asset, uint256 marketId, bytes32 sessionId, uint256 amount) external override {
        if (msg.sender != channelSettlement) revert OnlyChannelSettlement();
        if (asset == address(0) || amount == 0) revert Errors.InvalidAmount();
        if (_freeBalance[asset][user] < amount) revert InsufficientFreeBalance();
        _freeBalance[asset][user] -= amount;
        bytes32 key = _lockKey(asset, user, marketId, sessionId);
        _lockedBalance[key] += amount;
        emit Locked(user, asset, marketId, sessionId, amount);
    }

    function unlock(address user, address asset, uint256 marketId, bytes32 sessionId, uint256 amount) external override {
        if (msg.sender != channelSettlement) revert OnlyChannelSettlement();
        if (asset == address(0) || amount == 0) revert Errors.InvalidAmount();
        bytes32 key = _lockKey(asset, user, marketId, sessionId);
        if (_lockedBalance[key] < amount) revert InsufficientLockedBalance();
        _lockedBalance[key] -= amount;
        _freeBalance[asset][user] += amount;
        emit Unlocked(user, asset, marketId, sessionId, amount);
    }

    function applyCashDeltas(
        address asset,
        uint256 marketId,
        bytes32 sessionId,
        address[] calldata users,
        int128[] calldata cashDeltas
    ) external override {
        if (msg.sender != channelSettlement) revert OnlyChannelSettlement();
        if (users.length != cashDeltas.length) revert Errors.InvalidAmount();

        for (uint256 i = 0; i < users.length; i++) {
            address u = users[i];
            int128 delta = cashDeltas[i];
            if (delta == 0) continue;

            if (delta > 0) {
                uint256 d = int256(delta).toUint256();
                _freeBalance[asset][u] += d;
            } else {
                uint256 d = (-int256(delta)).toUint256();
                if (_freeBalance[asset][u] < d) revert InsufficientFreeBalance();
                _freeBalance[asset][u] -= d;
            }
        }
        emit CashDeltasApplied(asset, marketId, sessionId, users.length);
    }

    function redeemPayout(address to, address asset, uint256 amount) external override {
        if (msg.sender != marketRegistry) revert OnlyMarketRegistry();
        if (asset == address(0) || amount == 0) revert Errors.InvalidAmount();
        IERC20(asset).safeTransfer(to, amount);
    }

    function transferToFeeCollector(address to, address asset, uint256 amount) external {
        if (msg.sender != channelSettlement) revert OnlyChannelSettlement();
        if (to == address(0) || asset == address(0) || amount == 0) return;
        IERC20(asset).safeTransfer(to, amount);
    }

    /// @notice Transfer asset to any address. For protocol fee, lp fee, creator fee, net PnL. Only ChannelSettlement.
    function transferAsset(address to, address asset, uint256 amount) external {
        if (msg.sender != channelSettlement) revert OnlyChannelSettlement();
        if (to == address(0) || asset == address(0) || amount == 0) return;
        IERC20(asset).safeTransfer(to, amount);
    }

    function _lockKey(address asset, address user, uint256 marketId, bytes32 sessionId)
        internal
        pure
        returns (bytes32)
    {
        bytes32 key;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, asset)
            mstore(add(ptr, 0x20), user)
            mstore(add(ptr, 0x40), marketId)
            mstore(add(ptr, 0x60), sessionId)
            key := keccak256(ptr, 0x80)
        }
        return key;
    }
}
