// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Errors} from "../libraries/Errors.sol";

contract AccessManager {
    address public owner;
    mapping(address => bool) public operators;

    event OwnerTransferred(address indexed oldOwner, address indexed newOwner);
    event OperatorSet(address indexed operator, bool allowed);

    constructor(address _owner) {
        if (_owner == address(0)) revert Errors.InvalidAddress();
        owner = _owner;
        emit OwnerTransferred(address(0), _owner);
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    modifier onlyOperatorOrOwner() {
        _onlyOperatorOrOwner();
        _;
    }

    function _onlyOwner() internal view {
        if (msg.sender != owner) revert Errors.NotAuthorized();
    }

    function _onlyOperatorOrOwner() internal view {
        if (msg.sender != owner && !operators[msg.sender]) revert Errors.NotAuthorized();
    }

    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert Errors.InvalidAddress();
        emit OwnerTransferred(owner, newOwner);
        owner = newOwner;
    }

    function setOperator(address op, bool allowed) external onlyOwner {
        operators[op] = allowed;
        emit OperatorSet(op, allowed);
    }
}