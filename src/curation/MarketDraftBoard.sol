// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/// @title MarketDraftBoard
/// @notice Draft lifecycle: Proposed -> Claimed -> Published/Cancelled/Expired.
contract MarketDraftBoard is Ownable, AccessControl {
    bytes32 public constant AI_ORACLE_ROLE = keccak256("AI_ORACLE_ROLE");
    bytes32 public constant PUBLISH_CALLER_ROLE = keccak256("PUBLISH_CALLER_ROLE");

    enum DraftStatus {
        Proposed,
        Claimed,
        Published,
        Cancelled,
        Expired
    }

    enum MarketType {
        Binary,
        Categorical,
        Timeline
    }

    struct Draft {
        bytes32 questionHash;
        bytes32 questionUriHash;
        bytes32 outcomesHash;
        bytes32 outcomesUriHash;
        bytes32 resolveSpecHash;
        uint48 tradingOpen;
        uint48 tradingClose;
        uint48 resolveTime;
        MarketType marketType;
        DraftStatus status;
        address settlementAsset; // 0 = use policy default
        uint96 minSeed; // e.g. 50e6 for USDC; packed with settlementAsset
        address creator;
        uint48 proposedAt; // packed with creator
    }

    mapping(bytes32 => Draft) public drafts;
    bytes32[] private _draftIds;
    mapping(bytes32 => uint256) private _draftIdIndex;

    address public draftClaimManager;

    event DraftProposed(
        bytes32 indexed draftId,
        bytes32 questionHash,
        MarketType marketType,
        uint48 resolveTime,
        string questionURI,
        string outcomesURI
    );
    event DraftClaimed(bytes32 indexed draftId, address indexed claimer);
    event DraftPublished(bytes32 indexed draftId, uint256 indexed marketId);
    event DraftCancelled(bytes32 indexed draftId);
    event DraftExpired(bytes32 indexed draftId);
    event DraftClaimManagerUpdated(address indexed previous, address indexed current);

    error DraftDoesNotExist();
    error DraftNotProposed();
    error DraftNotClaimed();
    error DraftAlreadyPublished();
    error DraftAlreadyCancelled();
    error DraftAlreadyExpired();
    error UnauthorizedCaller();
    error InvalidOutcomeCount();
    error InvalidTimelineWindows();

    constructor() Ownable(msg.sender) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(AI_ORACLE_ROLE, msg.sender);
    }

    function setDraftClaimManager(address claimManager_) external onlyOwner {
        address previous = draftClaimManager;
        draftClaimManager = claimManager_;
        emit DraftClaimManagerUpdated(previous, claimManager_);
    }

    function grantPublishCaller(address caller) external onlyOwner {
        _grantRole(PUBLISH_CALLER_ROLE, caller);
    }

    function revokePublishCaller(address caller) external onlyOwner {
        _revokeRole(PUBLISH_CALLER_ROLE, caller);
    }

    /// @notice Propose a new draft. Only owner or AI_ORACLE_ROLE.
    function proposeDraft(
        bytes32 questionHash,
        string calldata questionUri_,
        MarketType marketType_,
        bytes32 outcomesHash,
        string calldata outcomesUri_,
        bytes32 resolveSpecHash_,
        uint48 tradingOpen_,
        uint48 tradingClose_,
        uint48 resolveTime_,
        address settlementAsset_,
        uint256 minSeed_
    ) external onlyRole(AI_ORACLE_ROLE) returns (bytes32 draftId) {
        draftId = _generateDraftId(questionHash);
        _storeDraft(
            draftId,
            questionHash,
            questionUri_,
            marketType_,
            outcomesHash,
            outcomesUri_,
            resolveSpecHash_,
            tradingOpen_,
            tradingClose_,
            resolveTime_,
            settlementAsset_,
            minSeed_
        );
        _draftIds.push(draftId);
        _draftIdIndex[draftId] = _draftIds.length - 1;
        emit DraftProposed(draftId, questionHash, marketType_, resolveTime_, questionUri_, outcomesUri_);
    }

    /// @notice Generate unique draft ID. Internal to reduce stack pressure in proposeDraft.
    function _generateDraftId(bytes32 questionHash) internal view returns (bytes32 draftId) {
        draftId = keccak256(
            abi.encodePacked(
                questionHash,
                block.timestamp,
                msg.sender,
                block.prevrandao
            )
        );
        if (drafts[draftId].proposedAt != 0) {
            draftId = keccak256(abi.encodePacked(draftId, block.timestamp));
        }
    }

    /// @notice Store draft fields. Internal to reduce stack pressure in proposeDraft.
    function _storeDraft(
        bytes32 draftId,
        bytes32 questionHash,
        string calldata questionUri_,
        MarketType marketType_,
        bytes32 outcomesHash,
        string calldata outcomesUri_,
        bytes32 resolveSpecHash_,
        uint48 tradingOpen_,
        uint48 tradingClose_,
        uint48 resolveTime_,
        address settlementAsset_,
        uint256 minSeed_
    ) internal {
        Draft storage newDraft = drafts[draftId];
        newDraft.questionHash = questionHash;
        newDraft.questionUriHash = keccak256(bytes(questionUri_));
        newDraft.marketType = marketType_;
        newDraft.outcomesHash = outcomesHash;
        newDraft.outcomesUriHash = keccak256(bytes(outcomesUri_));
        newDraft.resolveSpecHash = resolveSpecHash_;
        newDraft.tradingOpen = tradingOpen_;
        newDraft.tradingClose = tradingClose_;
        newDraft.resolveTime = resolveTime_;
        newDraft.settlementAsset = settlementAsset_;
        // forge-lint: disable-next-line(unsafe-typecast) -- minSeed is packed; 2^96 exceeds any realistic seed amount
        newDraft.minSeed = uint96(minSeed_);
        newDraft.status = DraftStatus.Proposed;
        newDraft.creator = address(0);
        newDraft.proposedAt = uint48(block.timestamp);
    }

    /// @notice Set draft to Claimed. Only DraftClaimManager.
    function setClaimed(bytes32 draftId, address claimer) external {
        if (msg.sender != draftClaimManager) revert UnauthorizedCaller();
        Draft storage d = drafts[draftId];
        if (d.proposedAt == 0) revert DraftDoesNotExist();
        if (d.status != DraftStatus.Proposed) revert DraftNotProposed();

        d.status = DraftStatus.Claimed;
        d.creator = claimer;

        emit DraftClaimed(draftId, claimer);
    }

    /// @notice Mark draft as Published. Only PUBLISH_CALLER_ROLE (e.g. MarketFactory).
    function markPublished(bytes32 draftId, uint256 marketId) external onlyRole(PUBLISH_CALLER_ROLE) {
        Draft storage d = drafts[draftId];
        if (d.proposedAt == 0) revert DraftDoesNotExist();
        if (d.status != DraftStatus.Claimed) revert DraftNotClaimed();

        d.status = DraftStatus.Published;

        emit DraftPublished(draftId, marketId);
    }

    /// @notice Cancel a draft. Owner only.
    function cancelDraft(bytes32 draftId) external onlyOwner {
        Draft storage d = drafts[draftId];
        if (d.proposedAt == 0) revert DraftDoesNotExist();
        if (d.status == DraftStatus.Published) revert DraftAlreadyPublished();
        if (d.status == DraftStatus.Cancelled) revert DraftAlreadyCancelled();
        if (d.status == DraftStatus.Expired) revert DraftAlreadyExpired();

        d.status = DraftStatus.Cancelled;

        emit DraftCancelled(draftId);
    }

    /// @notice Expire a draft. Owner only.
    function expireDraft(bytes32 draftId) external onlyOwner {
        Draft storage d = drafts[draftId];
        if (d.proposedAt == 0) revert DraftDoesNotExist();
        if (d.status == DraftStatus.Published) revert DraftAlreadyPublished();
        if (d.status == DraftStatus.Cancelled) revert DraftAlreadyCancelled();
        if (d.status == DraftStatus.Expired) revert DraftAlreadyExpired();

        d.status = DraftStatus.Expired;

        emit DraftExpired(draftId);
    }

    function getDraft(bytes32 draftId) external view returns (Draft memory) {
        return drafts[draftId];
    }

    function getStatus(bytes32 draftId) external view returns (DraftStatus) {
        return drafts[draftId].status;
    }

    function draftCount() external view returns (uint256) {
        return _draftIds.length;
    }

    function getDraftIdAt(uint256 index) external view returns (bytes32) {
        return _draftIds[index];
    }
}
