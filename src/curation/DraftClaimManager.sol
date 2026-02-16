// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MarketDraftBoard} from "./MarketDraftBoard.sol";
import {LiquidityVaultFactory} from "./LiquidityVaultFactory.sol";
import {LiquidityVault4626} from "../execution/LiquidityVault4626.sol";

/// @title DraftClaimManager
/// @notice claimDraft (legacy) and claimAndSeed (enforces min seed, deposits into vault).
contract DraftClaimManager is EIP712, Ownable {
    using ECDSA for bytes32;
    using SafeERC20 for IERC20;

    bytes32 public constant CLAIM_DRAFT_TYPEHASH =
        keccak256("ClaimDraft(bytes32 draftId,uint256 bond,bytes32 seedCommitment,uint256 expiry,uint256 nonce)");
    bytes32 public constant CLAIM_AND_SEED_TYPEHASH =
        keccak256("ClaimAndSeed(bytes32 draftId,address asset,uint256 seedAmount,uint256 deadline,uint256 nonce)");

    MarketDraftBoard public immutable draftBoard;
    LiquidityVaultFactory public liquidityVaultFactory;

    mapping(bytes32 => Claim) public claims;
    mapping(address => uint256) public nonces;

    mapping(bytes32 => uint256) public seedSharesLocked;
    mapping(bytes32 => uint48) public seedUnlockTime;
    mapping(bytes32 => address) public liquidityVaultByDraftId;

    struct Claim {
        address claimer;
        uint256 bond;
        bytes32 seedCommitment;
        uint256 claimedAt;
        uint256 expiry;
        address liquidityVault;
        uint256 seedShares;
    }

    event DraftClaimed(bytes32 indexed draftId, address indexed claimer, uint256 bond, bytes32 seedCommitment);
    event DraftClaimedAndSeeded(
        bytes32 indexed draftId,
        address indexed claimer,
        address indexed vault,
        uint256 seedAmount,
        uint256 seedShares
    );
    event SeedSharesUnlocked(bytes32 indexed draftId, address indexed claimer, uint256 shares);
    event LiquidityVaultFactoryUpdated(address indexed previous, address indexed current);

    error DraftDoesNotExist();
    error DraftNotProposed();
    error InvalidSignature();
    error ClaimExpired();
    error SeedTooLow();
    error AssetMismatch();
    error VaultFactoryNotSet();
    error SeedNotLocked();
    error UnlockTimeNotReached();

    constructor(address draftBoard_) EIP712("DraftClaimManager", "1") Ownable(msg.sender) {
        draftBoard = MarketDraftBoard(draftBoard_);
    }

    function setLiquidityVaultFactory(address factory) external onlyOwner {
        liquidityVaultFactory = LiquidityVaultFactory(factory);
        emit LiquidityVaultFactoryUpdated(address(0), factory);
    }

    /// @notice Claim a draft with seed deposit. Enforces minSeed, deposits into vault, locks shares until tradingClose.
    function claimAndSeed(
        bytes32 draftId,
        address asset,
        uint256 seedAmount,
        uint256 deadline,
        bytes calldata sig
    ) external {
        if (draftBoard.getStatus(draftId) != MarketDraftBoard.DraftStatus.Proposed) {
            if (draftBoard.getStatus(draftId) == MarketDraftBoard.DraftStatus.Claimed) revert DraftNotProposed();
            revert DraftDoesNotExist();
        }
        if (deadline != 0 && block.timestamp > deadline) revert ClaimExpired();
        if (address(liquidityVaultFactory) == address(0)) revert VaultFactoryNotSet();

        MarketDraftBoard.Draft memory d = draftBoard.getDraft(draftId);
        address settlementAsset = d.settlementAsset != address(0) ? d.settlementAsset : asset;
        if (asset != settlementAsset) revert AssetMismatch();

        uint256 minSeed = d.minSeed;
        if (seedAmount < minSeed) revert SeedTooLow();

        bytes32 structHash = keccak256(
            abi.encode(CLAIM_AND_SEED_TYPEHASH, draftId, asset, seedAmount, deadline, nonces[msg.sender])
        );
        bytes32 digest = _hashTypedDataV4(structHash);
        address signer = digest.recover(sig);
        if (signer != msg.sender) revert InvalidSignature();

        nonces[msg.sender]++;

        address vault = liquidityVaultFactory.createVaultForDraft(draftId, asset);
        if (LiquidityVault4626(vault).asset() != asset) revert AssetMismatch();

        IERC20(asset).safeTransferFrom(msg.sender, address(this), seedAmount);
        IERC20(asset).forceApprove(vault, seedAmount);
        uint256 shares = LiquidityVault4626(vault).deposit(seedAmount, msg.sender);

        seedSharesLocked[draftId] = shares;
        seedUnlockTime[draftId] = d.tradingClose != 0 ? d.tradingClose : uint48(block.timestamp);
        liquidityVaultByDraftId[draftId] = vault;

        claims[draftId] = Claim({
            claimer: msg.sender,
            bond: 0,
            seedCommitment: bytes32(0),
            claimedAt: block.timestamp,
            expiry: deadline,
            liquidityVault: vault,
            seedShares: shares
        });

        draftBoard.setClaimed(draftId, msg.sender);

        emit DraftClaimedAndSeeded(draftId, msg.sender, vault, seedAmount, shares);
    }

    /// @notice Unlock seed shares after tradingClose. For use with LiquidityLocker; no-op if no lock.
    function unlockSeedShares(bytes32 draftId) external {
        if (seedSharesLocked[draftId] == 0) revert SeedNotLocked();
        if (block.timestamp < seedUnlockTime[draftId]) revert UnlockTimeNotReached();
        address claimer = claims[draftId].claimer;
        uint256 shares = seedSharesLocked[draftId];
        seedSharesLocked[draftId] = 0;
        emit SeedSharesUnlocked(draftId, claimer, shares);
    }

    function getLiquidityVault(bytes32 draftId) external view returns (address) {
        return liquidityVaultByDraftId[draftId];
    }

    /// @notice Claim a draft (legacy, no seed). Requires EIP-712 signature from claimer.
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
            expiry: expiry,
            liquidityVault: address(0),
            seedShares: 0
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

    /// @notice For tests: compute EIP-712 digest for ClaimAndSeed.
    function digestClaimAndSeed(
        bytes32 draftId,
        address asset,
        uint256 seedAmount,
        uint256 deadline,
        address signer
    ) external view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(CLAIM_AND_SEED_TYPEHASH, draftId, asset, seedAmount, deadline, nonces[signer])
        );
        return _hashTypedDataV4(structHash);
    }
}
