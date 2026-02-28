// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IMarketRiskManager} from "../interfaces/IMarketRiskManager.sol";
import {Errors} from "../utils/Errors.sol";

/// @title MarketRiskManager
/// @notice Caps LP underwriting per market; reserves capital when LP owes traders.
contract MarketRiskManager is IMarketRiskManager, Ownable {
    mapping(uint256 => uint256) private _maxLpPayout;
    mapping(uint256 => uint256) private _reservedLpPayout;

    address public marketFactory;

    modifier onlyChannelSettlement() {
        if (msg.sender != channelSettlement) revert Errors.Unauthorized();
        _;
    }

    modifier onlySetter() {
        if (msg.sender != owner() && msg.sender != marketFactory) revert Errors.Unauthorized();
        _;
    }

    address public channelSettlement;

    event MaxLpPayoutSet(uint256 indexed marketId, uint256 cap);
    event LpPayoutReserved(uint256 indexed marketId, uint256 amount);
    event ChannelSettlementUpdated(address indexed previous, address indexed current);
    event MarketFactoryUpdated(address indexed previous, address indexed current);

    constructor() Ownable(msg.sender) {}

    function setChannelSettlement(address cs) external onlyOwner {
        if (cs == address(0)) revert Errors.InvalidAddress();
        address previous = channelSettlement;
        channelSettlement = cs;
        emit ChannelSettlementUpdated(previous, cs);
    }

    function setMarketFactory(address mf) external onlyOwner {
        address previous = marketFactory;
        marketFactory = mf;
        emit MarketFactoryUpdated(previous, mf);
    }

    function setMaxLpPayout(uint256 marketId, uint256 cap) external override onlySetter {
        _maxLpPayout[marketId] = cap;
        emit MaxLpPayoutSet(marketId, cap);
    }

    function maxLpPayout(uint256 marketId) external view override returns (uint256) {
        return _maxLpPayout[marketId];
    }

    function reservedLpPayout(uint256 marketId) external view override returns (uint256) {
        return _reservedLpPayout[marketId];
    }

    function reserveLpPayout(uint256 marketId, uint256 amount) external override onlyChannelSettlement {
        uint256 cap = _maxLpPayout[marketId];
        uint256 reserved = _reservedLpPayout[marketId];
        if (reserved + amount > cap) revert Errors.RiskCapExceeded();
        _reservedLpPayout[marketId] = reserved + amount;
        emit LpPayoutReserved(marketId, amount);
    }
}
