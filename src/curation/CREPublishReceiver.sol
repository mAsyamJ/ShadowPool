// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ReceiverTemplate} from "../interfaces/ReceiverTemplate.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MarketDraftBoard} from "./MarketDraftBoard.sol";
import {DraftClaimManager} from "./DraftClaimManager.sol";
import {MarketPolicy} from "./MarketPolicy.sol";

/// @notice Interface for MarketFactory.createFromDraft
interface IMarketFactoryFromDraft {
    struct DraftPublishParams {
        string question;
        uint8 marketType;
        string[] outcomes;
        uint48[] timelineWindows;
        uint48 resolveTime;
        uint48 tradingOpen;
        uint48 tradingClose;
    }

    function createFromDraft(
        bytes32 draftId,
        address creator,
        DraftPublishParams calldata params
    ) external returns (uint256 marketId);
}

/// @title CREPublishReceiver
/// @notice CRE entrypoint for publish-from-draft (schema 0x04). Extends ReceiverTemplate.
contract CREPublishReceiver is ReceiverTemplate, EIP712 {
    using ECDSA for bytes32;

    bytes32 public constant PUBLISH_FROM_DRAFT_TYPEHASH =
        keccak256(
            "PublishFromDraft(bytes32 draftId,bytes32 paramsHash,uint256 chainId,uint256 nonce)"
        );

    MarketDraftBoard public immutable DRAFT_BOARD;
    DraftClaimManager public immutable DRAFT_CLAIM_MANAGER;
    MarketPolicy public immutable MARKET_POLICY;
    IMarketFactoryFromDraft public immutable MARKET_FACTORY;

    mapping(address => uint256) public publishNonces;

    event DraftPublished(bytes32 indexed draftId, address indexed creator, uint256 indexed marketId);

    error DraftNotClaimed();
    error InvalidCreator();
    error InvalidSignature();
    error InvalidParamsHash();

    constructor(
        address forwarderAddress,
        address draftBoard_,
        address draftClaimManager_,
        address marketPolicy_,
        address marketFactory_
    ) ReceiverTemplate(forwarderAddress) EIP712("CREPublishReceiver", "1") {
        DRAFT_BOARD = MarketDraftBoard(draftBoard_);
        DRAFT_CLAIM_MANAGER = DraftClaimManager(draftClaimManager_);
        MARKET_POLICY = MarketPolicy(marketPolicy_);
        MARKET_FACTORY = IMarketFactoryFromDraft(marketFactory_);
    }

    /// @notice Process report. Schema 0x04: publish from draft.
    /// @dev Report format: [0x04?] abi.encode(draftId, creator, params, claimerSig)
    function _processReport(bytes calldata report) internal override {
        bytes calldata payload = report.length > 0 && report[0] == 0x04 ? report[1:] : report;
        (
            bytes32 draftId,
            address creator,
            IMarketFactoryFromDraft.DraftPublishParams memory params,
            bytes memory claimerSig
        ) = abi.decode(payload, (bytes32, address, IMarketFactoryFromDraft.DraftPublishParams, bytes));

        if (DRAFT_BOARD.getStatus(draftId) != MarketDraftBoard.DraftStatus.Claimed) {
            revert DraftNotClaimed();
        }
        if (DRAFT_CLAIM_MANAGER.getClaimer(draftId) != creator) {
            revert InvalidCreator();
        }

        bytes memory encodedParams = abi.encode(
            params.question,
            params.marketType,
            keccak256(abi.encode(params.outcomes)),
            keccak256(abi.encode(params.timelineWindows)),
            params.resolveTime,
            params.tradingOpen,
            params.tradingClose
        );
        bytes32 paramsHash;
        assembly ("memory-safe") {
            paramsHash := keccak256(add(encodedParams, 0x20), mload(encodedParams))
        }

        bytes32 structHash = _hashPublishFromDraft(draftId, paramsHash, publishNonces[creator]);
        bytes32 digest = _hashTypedDataV4(structHash);
        address signer = digest.recover(claimerSig);
        if (signer != creator) revert InvalidSignature();

        publishNonces[creator]++;

        MarketDraftBoard.Draft memory d = DRAFT_BOARD.getDraft(draftId);
        MARKET_POLICY.validateDraftWithOutcomesCount(d, _outcomesCount(params));

        uint256 marketId = MARKET_FACTORY.createFromDraft(draftId, creator, params);

        emit DraftPublished(draftId, creator, marketId);
    }

    function _outcomesCount(IMarketFactoryFromDraft.DraftPublishParams memory params)
        internal
        pure
        returns (uint8)
    {
        if (params.marketType == 2) return uint8(params.timelineWindows.length);
        if (params.marketType == 1) return uint8(params.outcomes.length);
        return 2;
    }

    /// @notice For tests: compute EIP-712 digest for PublishFromDraft.
    function digestPublishFromDraft(
        bytes32 draftId,
        bytes32 paramsHash,
        address signer
    ) external view returns (bytes32) {
        bytes32 structHash = _hashPublishFromDraft(draftId, paramsHash, publishNonces[signer]);
        return _hashTypedDataV4(structHash);
    }

    function _hashPublishFromDraft(bytes32 draftId, bytes32 paramsHash, uint256 nonce)
        internal
        view
        returns (bytes32 digest)
    {
        bytes32 typeHash = PUBLISH_FROM_DRAFT_TYPEHASH;
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(ptr, typeHash)
            mstore(add(ptr, 0x20), draftId)
            mstore(add(ptr, 0x40), paramsHash)
            mstore(add(ptr, 0x60), chainid())
            mstore(add(ptr, 0x80), nonce)
            digest := keccak256(ptr, 0xa0)
        }
    }
}
