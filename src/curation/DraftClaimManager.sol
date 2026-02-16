// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MarketDraftBoard} from "./MarketDraftBoard.sol";

/// @title DraftClaimManager
/// @notice claimDraft(draftId, bond, seedCommitment, sig) with EIP-712.
contract DraftClaimManager is EIP712 {
    using ECDSA for bytes32;

    bytes32 public constant CLAIM_DRAFT_TYPEHASH =
        keccak256("ClaimDraft(bytes32 draftId,uint256 bond,bytes32 seedCommitment,uint256 expiry,uint256 nonce)");

    MarketDraftBoard public immutable draftBoard;

    mapping(bytes32 => Claim) public claims;
    mapping(address => uint256) public nonces;

    struct Claim {
        address claimer;
        uint256 bond;
        bytes32 seedCommitment;
        uint256 claimedAt;
        uint256 expiry;
    }

    event DraftClaimed(bytes32 indexed draftId, address indexed claimer, uint256 bond, bytes32 seedCommitment);

    error DraftDoesNotExist();
    error DraftNotProposed();
    error InvalidSignature();
    error ClaimExpired();

    constructor(address draftBoard_) EIP712("DraftClaimManager", "1") {
        draftBoard = MarketDraftBoard(draftBoard_);
    }

    /// @notice Claim a draft. Requires EIP-712 signature from claimer.
    function claimDraft(
        bytes32 draftId,
        uint256 bond,
        bytes32 seedCommitment,
        uint256 expiry,
        bytes calldata sig
    ) external {
        if (draftBoard.getStatus(draftId) != MarketDraftBoard.DraftStatus.Proposed) {
            if (draftBoard.getStatus(draftId) == MarketDraftBoard.DraftStatus.Claimed) {
                revert DraftNotProposed();
            }
            revert DraftDoesNotExist();
        }
        if (expiry != 0 && block.timestamp > expiry) revert ClaimExpired();

        bytes32 structHash = keccak256(
            abi.encode(CLAIM_DRAFT_TYPEHASH, draftId, bond, seedCommitment, expiry, nonces[msg.sender])
        );
        bytes32 digest = _hashTypedDataV4(structHash);
        address signer = digest.recover(sig);
        if (signer != msg.sender) revert InvalidSignature();

        nonces[msg.sender]++;

        claims[draftId] = Claim({
            claimer: msg.sender,
            bond: bond,
            seedCommitment: seedCommitment,
            claimedAt: block.timestamp,
            expiry: expiry
        });

        draftBoard.setClaimed(draftId, msg.sender);

        emit DraftClaimed(draftId, msg.sender, bond, seedCommitment);
    }

    function getClaimer(bytes32 draftId) external view returns (address) {
        return claims[draftId].claimer;
    }

    function getClaim(bytes32 draftId) external view returns (Claim memory) {
        return claims[draftId];
    }

    /// @notice For tests: compute EIP-712 digest for ClaimDraft.
    function digestClaimDraft(
        bytes32 draftId,
        uint256 bond,
        bytes32 seedCommitment,
        uint256 expiry,
        address signer
    ) external view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(CLAIM_DRAFT_TYPEHASH, draftId, bond, seedCommitment, expiry, nonces[signer])
        );
        return _hashTypedDataV4(structHash);
    }
}
