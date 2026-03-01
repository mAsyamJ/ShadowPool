// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ICollateralVault} from "../interfaces/ICollateralVault.sol";
import {Errors} from "../utils/Errors.sol";

/// @title CollateralVault
/// @notice Single custody point for ShadowPool: deposit/withdraw, lock/unlock per session.
contract CollateralVault is ICollateralVault, Ownable {
    using SafeERC20 for IERC20;
    using SafeCast for int256;

    function token() external view override returns (address) {
        return address(TOKEN_CONTRACT);
    }
    IERC20 public immutable TOKEN_CONTRACT;

    address public channelSettlement;
    address public marketRegistry;

    mapping(address => uint256) private _freeBalance;
    mapping(address => uint256) private _reservedBalance;
    mapping(bytes32 => uint256) private _lockedBalance; // keccak256(user, marketId, sessionId) => amount

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Locked(address indexed user, uint256 marketId, bytes32 sessionId, uint256 amount);
    event Unlocked(address indexed user, uint256 marketId, bytes32 sessionId, uint256 amount);
    event ChannelSettlementUpdated(address indexed previous, address indexed current);
    event MarketRegistryUpdated(address indexed previous, address indexed current);
    event CashDeltasApplied(uint256 indexed marketId, bytes32 indexed sessionId, uint256 userCount);
    event Reserved(address indexed user, uint256 amount);
    event Released(address indexed user, uint256 amount);

    error OnlyChannelSettlement();
    error InsufficientFreeBalance();
    error InsufficientLockedBalance();
    error NegativeResult();
    error OnlyMarketRegistry();

    constructor(address tokenAddress, address channelSettlement_) Ownable(msg.sender) {
        if (tokenAddress == address(0)) revert Errors.InvalidAddress();
        TOKEN_CONTRACT = IERC20(tokenAddress);
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

    function deposit(uint256 amount) external override {
        if (amount == 0) revert Errors.InvalidAmount();
        _freeBalance[msg.sender] += amount;
        TOKEN_CONTRACT.safeTransferFrom(msg.sender, address(this), amount);
        emit Deposited(msg.sender, amount);
    }

    function withdraw(uint256 amount) external override {
        if (amount == 0) revert Errors.InvalidAmount();
        uint256 free = _freeBalance[msg.sender];
        uint256 reserved = _reservedBalance[msg.sender];
        if (free < reserved + amount) revert Errors.InsufficientAvailableBalance();
        _freeBalance[msg.sender] = free - amount;
        TOKEN_CONTRACT.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function freeBalance(address user) external view override returns (uint256) {
        return _freeBalance[user];
    }

    function reservedBalance(address user) external view override returns (uint256) {
        return _reservedBalance[user];
    }

    function availableBalance(address user) external view override returns (uint256) {
        uint256 free = _freeBalance[user];
        uint256 reserved = _reservedBalance[user];
        return free > reserved ? free - reserved : 0;
    }

    function reserve(address user, uint256 amount) external override {
        if (msg.sender != channelSettlement) revert OnlyChannelSettlement();
        if (amount == 0) revert Errors.InvalidAmount();

        uint256 free = _freeBalance[user];
        uint256 res = _reservedBalance[user];
        if (free < res + amount) revert Errors.InsufficientAvailableBalance();

        _reservedBalance[user] = res + amount;
        emit Reserved(user, amount);
    }

    function release(address user, uint256 amount) external override {
        if (msg.sender != channelSettlement) revert OnlyChannelSettlement();
        if (amount == 0) revert Errors.InvalidAmount();

        uint256 res = _reservedBalance[user];
        if (res < amount) revert Errors.InsufficientReservedBalance();

        _reservedBalance[user] = res - amount;
        emit Released(user, amount);
    }

    function lockedBalance(address user, uint256 marketId, bytes32 sessionId) external view override returns (uint256) {
        return _lockedBalance[_lockKey(user, marketId, sessionId)];
    }

    function lock(address user, uint256 marketId, bytes32 sessionId, uint256 amount) external override {
        if (msg.sender != channelSettlement) revert OnlyChannelSettlement();
        if (amount == 0) revert Errors.InvalidAmount();
        if (_freeBalance[user] < amount) revert InsufficientFreeBalance();
        _freeBalance[user] -= amount;
        bytes32 key = _lockKey(user, marketId, sessionId);
        _lockedBalance[key] += amount;
        emit Locked(user, marketId, sessionId, amount);
    }

    function unlock(address user, uint256 marketId, bytes32 sessionId, uint256 amount) external override {
        if (msg.sender != channelSettlement) revert OnlyChannelSettlement();
        if (amount == 0) revert Errors.InvalidAmount();
        bytes32 key = _lockKey(user, marketId, sessionId);
        if (_lockedBalance[key] < amount) revert InsufficientLockedBalance();
        _lockedBalance[key] -= amount;
        _freeBalance[user] += amount;
        emit Unlocked(user, marketId, sessionId, amount);
    }

    function applyCashDeltas(
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
                // Credit user
                uint256 d = int256(delta).toUint256();
                _freeBalance[u] += d;
            } else {
                // Debit user (e.g. trade cost)
                uint256 d = (-int256(delta)).toUint256();
                if (_freeBalance[u] < d) revert InsufficientFreeBalance();
                _freeBalance[u] -= d;
            }
        }
        emit CashDeltasApplied(marketId, sessionId, users.length);
    }

    function redeemPayout(address to, uint256 amount) external override {
        if (msg.sender != marketRegistry) revert OnlyMarketRegistry();
        if (amount == 0) revert Errors.InvalidAmount();
        TOKEN_CONTRACT.safeTransfer(to, amount);
    }

    /// @notice Transfer tokens to fee collector (e.g. FeePool); only ChannelSettlement.
    function transferToFeeCollector(address to, uint256 amount) external {
        if (msg.sender != channelSettlement) revert OnlyChannelSettlement();
        if (to == address(0) || amount == 0) return;
        TOKEN_CONTRACT.safeTransfer(to, amount);
    }

    function _lockKey(address user, uint256 marketId, bytes32 sessionId) internal pure returns (bytes32) {
        bytes32 key;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, user)
            mstore(add(ptr, 0x20), marketId)
            mstore(add(ptr, 0x40), sessionId)
            key := keccak256(ptr, 0x60)
        }
        return key;
    }
}
