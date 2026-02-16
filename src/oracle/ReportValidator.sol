// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Errors} from "../utils/Errors.sol";

/// @title ReportValidator
/// @notice Optional confidence gate for oracle results.
contract ReportValidator is Ownable {
    uint16 public minConfidence;

    event MinConfidenceUpdated(uint16 previous, uint16 current);

    constructor(uint16 minConfidence_) Ownable(msg.sender) {
        minConfidence = minConfidence_;
    }

    function setMinConfidence(uint16 value) external onlyOwner {
        uint16 previous = minConfidence;
        minConfidence = value;
        emit MinConfidenceUpdated(previous, value);
    }

    function validate(uint16 confidence) external view {
        if (confidence < minConfidence) revert Errors.InvalidConfidence();
    }
}
