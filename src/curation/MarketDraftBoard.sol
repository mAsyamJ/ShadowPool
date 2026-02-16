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
        string questionURI;
        MarketType marketType;
        bytes32 outcomesHash;
        string outcomesURI;
        bytes32 resolveSpecHash;
        uint48 tradingOpen;
        uint48 tradingClose;
        uint48 resolveTime;
        address settlementAsset; // 0 = use policy default
        uint256 minSeed; // e.g. 50e6 for USDC
        DraftStatus status;
        address creator;
        uint256 proposedAt;
    }

    mapping(bytes32 => Draft) public drafts;
    bytes32[] private _draftIds;
    mapping(bytes32 => uint256) private _draftIdIndex;

    address public draftClaimManager;

    event DraftProposed(bytes32 indexed draftId, bytes32 questionHash, MarketType marketType, uint48 resolveTime);
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
        string calldata questionURI_,
        MarketType marketType_,
        bytes32 outcomesHash,
        string calldata outcomesURI_,
        bytes32 resolveSpecHash_,
        uint48 tradingOpen_,
        uint48 tradingClose_,
        uint48 resolveTime_,
        address settlementAsset_,
        uint256 minSeed_
    ) external onlyRole(AI_ORACLE_ROLE) returns (bytes32 draftId) {
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

        drafts[draftId] = Draft({
            questionHash: questionHash,
            questionURI: questionURI_,
            marketType: marketType_,
            outcomesHash: outcomesHash,
            outcomesURI: outcomesURI_,
            resolveSpecHash: resolveSpecHash_,
            tradingOpen: tradingOpen_,
            tradingClose: tradingClose_,
            resolveTime: resolveTime_,
            settlementAsset: settlementAsset_,
            minSeed: minSeed_,
            status: DraftStatus.Proposed,
            creator: address(0),
            proposedAt: block.timestamp
        });

        _draftIds.push(draftId);
        _draftIdIndex[draftId] = _draftIds.length - 1;

        emit DraftProposed(draftId, questionHash, marketType_, resolveTime_);
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
