// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {MarketDraftBoard} from "../src/curation/MarketDraftBoard.sol";
import {DraftClaimManager} from "../src/curation/DraftClaimManager.sol";
import {MarketPolicy} from "../src/curation/MarketPolicy.sol";
import {CREPublishReceiver} from "../src/curation/CREPublishReceiver.sol";
import {MarketFactory} from "../src/core/MarketFactory.sol";
import {MarketRegistry} from "../src/core/MarketRegistry.sol";
import {CollateralVault} from "../src/execution/CollateralVault.sol";
import {ExecutionLedger} from "../src/execution/ExecutionLedger.sol";
import {LiquidityVaultFactory} from "../src/curation/LiquidityVaultFactory.sol";
import {LiquidityVault4626} from "../src/execution/LiquidityVault4626.sol";

contract CurationFlowTest is Test {
    address forwarder = address(0x1234);
    address creator;
    uint256 creatorPk = 0xBEEF;

    ERC20Mock token;
    CollateralVault vault;
    ExecutionLedger ledger;
    MarketRegistry marketRegistry;
    MarketDraftBoard draftBoard;
    DraftClaimManager draftClaimManager;
    MarketPolicy marketPolicy;
    CREPublishReceiver crePublishReceiver;
    MarketFactory marketFactory;

    function setUp() public {
        vm.warp(1000);
        creator = vm.addr(creatorPk);

        token = new ERC20Mock();
        token.mint(address(this), 1000 ether);

        vault = new CollateralVault(address(token), address(0));
        ledger = new ExecutionLedger(address(0));
        marketRegistry = new MarketRegistry(address(vault), address(ledger));

        draftBoard = new MarketDraftBoard();
        draftClaimManager = new DraftClaimManager(address(draftBoard));
        draftBoard.setDraftClaimManager(address(draftClaimManager));

        marketPolicy = new MarketPolicy();
        marketFactory = new MarketFactory(forwarder, address(marketRegistry));
        marketRegistry.setMarketFactory(address(marketFactory));

        crePublishReceiver = new CREPublishReceiver(
            forwarder,
            address(draftBoard),
            address(draftClaimManager),
            address(marketPolicy),
            address(marketFactory)
        );

        marketFactory.setMarketRegistry(address(marketRegistry));
        marketFactory.setDraftBoard(address(draftBoard));
        marketFactory.setPublishReceiverApproved(address(crePublishReceiver), true);
        draftBoard.grantPublishCaller(address(marketFactory));
    }

    function testDraftPipelineProposeClaimPublishCreatesMarket() public {
        console2.log("[TEST] testDraftPipelineProposeClaimPublishCreatesMarket");
        console2.log("[ARRANGE] Propose draft with seed, claimAndSeed, then publish");
        LiquidityVaultFactory vaultFactory = new LiquidityVaultFactory(address(0));
        vm.prank(draftClaimManager.owner());
        draftClaimManager.setLiquidityVaultFactory(address(vaultFactory));
        marketFactory.setDraftClaimManager(address(draftClaimManager));

        token.mint(creator, 100 ether);
        vm.prank(creator);
        token.approve(address(draftClaimManager), 100 ether);

        bytes32 draftId = _proposeDraftWithSeed(address(token), 1);
        _claimAndSeed(draftId);
        _publishDraft(draftId);

        console2.log("[ASSERT] Draft is published and market metadata matches creator/question");
        assertEq(uint8(draftBoard.getStatus(draftId)), uint8(MarketDraftBoard.DraftStatus.Published));
        assertEq(marketFactory.draftIdByMarketId(0), draftId);
        MarketRegistry.Market memory m = marketRegistry.getMarket(0);
        assertEq(m.creator, creator);
        assertEq(m.question, "Will X happen?");
    }

    function testClaimAndSeedPipeline() public {
        console2.log("[TEST] testClaimAndSeedPipeline");
        console2.log("[ARRANGE] Enable liquidity vault factory and fund creator for seed");
        LiquidityVaultFactory vaultFactory = new LiquidityVaultFactory(address(0));
        vm.prank(draftClaimManager.owner());
        draftClaimManager.setLiquidityVaultFactory(address(vaultFactory));
        marketFactory.setDraftClaimManager(address(draftClaimManager));

        token.mint(creator, 100 ether);
        vm.prank(creator);
        token.approve(address(draftClaimManager), 100 ether);

        bytes32 draftId = _proposeDraftWithSeed(address(token), 50 ether);
        console2.log("[ACT] claimAndSeed + publish flow");
        _claimAndSeed(draftId);
        _publishDraft(draftId);

        console2.log("[ASSERT] Published draft creates market with linked liquidity vault");
        assertEq(uint8(draftBoard.getStatus(draftId)), uint8(MarketDraftBoard.DraftStatus.Published));
        assertEq(marketRegistry.getCreator(0), creator);
        assertTrue(marketRegistry.liquidityVaultByMarketId(0) != address(0));
    }

    function testPublishRequiresSeedWhenMinSeedPositive() public {
        console2.log("[TEST] testPublishRequiresSeedWhenMinSeedPositive");
        console2.log("[ARRANGE] Draft requires seed, but creator uses legacy claim path (no seed)");
        LiquidityVaultFactory vaultFactory = new LiquidityVaultFactory(address(0));
        vm.prank(draftClaimManager.owner());
        draftClaimManager.setLiquidityVaultFactory(address(vaultFactory));
        marketFactory.setDraftClaimManager(address(draftClaimManager));

        bytes32 draftId = _proposeDraftWithSeed(address(token), 50 ether);
        _claimDraft(draftId); // legacy claim path, no seed

        IMarketFactoryFromDraft.DraftPublishParams memory params = IMarketFactoryFromDraft.DraftPublishParams({
            question: "Will X happen?",
            marketType: 0,
            outcomes: _strs("Yes", "No"),
            timelineWindows: new uint48[](0),
            resolveTime: uint48(block.timestamp + 86400),
            tradingOpen: 0,
            tradingClose: uint48(block.timestamp + 86400)
        });
        bytes32 paramsHash = keccak256(
            abi.encode(
                params.question,
                params.marketType,
                keccak256(abi.encode(params.outcomes)),
                keccak256(abi.encode(params.timelineWindows)),
                params.resolveTime,
                params.tradingOpen,
                params.tradingClose
            )
        );
        bytes32 publishDigest = crePublishReceiver.digestPublishFromDraft(draftId, paramsHash, creator);
        (uint8 pv, bytes32 pr, bytes32 ps) = vm.sign(creatorPk, publishDigest);
        bytes memory report = abi.encode(draftId, creator, params, abi.encodePacked(pr, ps, pv));
        console2.log("[ASSERT] Publish report reverts with SeededClaimRequired");
        vm.prank(forwarder);
        vm.expectRevert(MarketFactory.SeededClaimRequired.selector);
        crePublishReceiver.onReport("", report);
    }

    function testPublishRejectsDraftTimeMismatch() public {
        console2.log("[TEST] testPublishRejectsDraftTimeMismatch");
        console2.log("[ARRANGE] Publish params use tradingClose different from proposed draft");
        LiquidityVaultFactory vaultFactory = new LiquidityVaultFactory(address(0));
        vm.prank(draftClaimManager.owner());
        draftClaimManager.setLiquidityVaultFactory(address(vaultFactory));
        marketFactory.setDraftClaimManager(address(draftClaimManager));

        token.mint(creator, 100 ether);
        vm.prank(creator);
        token.approve(address(draftClaimManager), 100 ether);

        bytes32 draftId = _proposeDraftWithSeed(address(token), 1);
        _claimAndSeed(draftId);

        IMarketFactoryFromDraft.DraftPublishParams memory params = IMarketFactoryFromDraft.DraftPublishParams({
            question: "Will X happen?",
            marketType: 0,
            outcomes: _strs("Yes", "No"),
            timelineWindows: new uint48[](0),
            resolveTime: uint48(block.timestamp + 86400),
            tradingOpen: 0,
            tradingClose: uint48(block.timestamp + 90000) // mismatch from draft
        });
        bytes32 paramsHash = keccak256(
            abi.encode(
                params.question,
                params.marketType,
                keccak256(abi.encode(params.outcomes)),
                keccak256(abi.encode(params.timelineWindows)),
                params.resolveTime,
                params.tradingOpen,
                params.tradingClose
            )
        );
        bytes32 publishDigest = crePublishReceiver.digestPublishFromDraft(draftId, paramsHash, creator);
        (uint8 pv, bytes32 pr, bytes32 ps) = vm.sign(creatorPk, publishDigest);
        bytes memory report = abi.encode(draftId, creator, params, abi.encodePacked(pr, ps, pv));
        console2.log("[ASSERT] Publish report reverts with DraftTimeMismatch");
        vm.prank(forwarder);
        vm.expectRevert(MarketFactory.DraftTimeMismatch.selector);
        crePublishReceiver.onReport("", report);
    }

    function testClaimAndSeedLocksSharesInManager() public {
        console2.log("[TEST] testClaimAndSeedLocksSharesInManager");
        console2.log("[ARRANGE] claimAndSeed called with valid creator signature");
        LiquidityVaultFactory vaultFactory = new LiquidityVaultFactory(address(0));
        vm.prank(draftClaimManager.owner());
        draftClaimManager.setLiquidityVaultFactory(address(vaultFactory));
        marketFactory.setDraftClaimManager(address(draftClaimManager));

        token.mint(creator, 100 ether);
        vm.prank(creator);
        token.approve(address(draftClaimManager), 100 ether);

        bytes32 draftId = _proposeDraftWithSeed(address(token), 50 ether);
        _claimAndSeed(draftId);

        console2.log("[ASSERT] Manager custody holds vault shares; creator has none directly");
        address lv = draftClaimManager.getLiquidityVault(draftId);
        assertTrue(lv != address(0));
        assertEq(LiquidityVault4626(lv).balanceOf(creator), 0, "creator should not directly hold locked shares");
        assertGt(LiquidityVault4626(lv).balanceOf(address(draftClaimManager)), 0, "manager must custody locked shares");
    }

    function testVaultFactoryWrongAssetCanBeReplaced() public {
        console2.log("[TEST] testVaultFactoryWrongAssetCanBeReplaced");
        console2.log("[ARRANGE] Pre-create wrong-asset vault for same draft id");
        LiquidityVaultFactory vaultFactory = new LiquidityVaultFactory(address(0));
        vm.prank(draftClaimManager.owner());
        draftClaimManager.setLiquidityVaultFactory(address(vaultFactory));
        marketFactory.setDraftClaimManager(address(draftClaimManager));

        ERC20Mock other = new ERC20Mock();
        bytes32 draftId = _proposeDraftWithSeed(address(token), 50 ether);

        // attacker pre-creates wrong-asset vault for the same draft
        address wrong = vaultFactory.createVaultForDraft(draftId, address(other));
        assertEq(LiquidityVault4626(wrong).asset(), address(other));

        token.mint(creator, 100 ether);
        vm.prank(creator);
        token.approve(address(draftClaimManager), 100 ether);

        // claimAndSeed should recreate/replace with correct-asset vault and succeed
        console2.log("[ACT] claimAndSeed should replace wrong vault with token-backed vault");
        _claimAndSeed(draftId);
        address lv = draftClaimManager.getLiquidityVault(draftId);
        console2.log("[ASSERT] Final vault asset equals settlement token");
        assertEq(LiquidityVault4626(lv).asset(), address(token));
    }

    function testUnlockSeedSharesBeforeTradingCloseReverts() public {
        console2.log("[TEST] testUnlockSeedSharesBeforeTradingCloseReverts");
        console2.log("[ARRANGE] Claim-and-seed draft, then warp before trading close");
        LiquidityVaultFactory vaultFactory = new LiquidityVaultFactory(address(0));
        vm.prank(draftClaimManager.owner());
        draftClaimManager.setLiquidityVaultFactory(address(vaultFactory));
        marketFactory.setDraftClaimManager(address(draftClaimManager));

        token.mint(creator, 100 ether);
        vm.prank(creator);
        token.approve(address(draftClaimManager), 100 ether);

        bytes32 draftId = _proposeDraftWithSeed(address(token), 50 ether);
        _claimAndSeed(draftId);

        console2.log("[ASSERT] Unlocking seed shares before unlock time reverts");
        vm.warp(block.timestamp + 1000);
        vm.expectRevert(DraftClaimManager.UnlockTimeNotReached.selector);
        draftClaimManager.unlockSeedShares(draftId);
    }

    function testPublishWithLegacyClaimRevertsWhenSeededRequired() public {
        console2.log("[TEST] testPublishWithLegacyClaimRevertsWhenSeededRequired");
        console2.log("[ARRANGE] Seed-required draft is claimed with legacy (non-seeded) claim path");
        LiquidityVaultFactory vaultFactory = new LiquidityVaultFactory(address(0));
        vm.prank(draftClaimManager.owner());
        draftClaimManager.setLiquidityVaultFactory(address(vaultFactory));
        marketFactory.setDraftClaimManager(address(draftClaimManager));

        bytes32 draftId = _proposeDraftWithSeed(address(token), 0);
        _claimDraft(draftId);

        IMarketFactoryFromDraft.DraftPublishParams memory params = IMarketFactoryFromDraft.DraftPublishParams({
            question: "Will X happen?",
            marketType: 0,
            outcomes: _strs("Yes", "No"),
            timelineWindows: new uint48[](0),
            resolveTime: uint48(block.timestamp + 86400),
            tradingOpen: 0,
            tradingClose: uint48(block.timestamp + 86400)
        });
        bytes32 paramsHash = keccak256(
            abi.encode(
                params.question,
                params.marketType,
                keccak256(abi.encode(params.outcomes)),
                keccak256(abi.encode(params.timelineWindows)),
                params.resolveTime,
                params.tradingOpen,
                params.tradingClose
            )
        );
        bytes32 publishDigest = crePublishReceiver.digestPublishFromDraft(draftId, paramsHash, creator);
        (uint8 pv, bytes32 pr, bytes32 ps) = vm.sign(creatorPk, publishDigest);
        bytes memory report = abi.encode(draftId, creator, params, abi.encodePacked(pr, ps, pv));
        console2.log("[ASSERT] Publish via CRE receiver reverts with SeededClaimRequired");
        vm.prank(forwarder);
        vm.expectRevert(MarketFactory.SeededClaimRequired.selector);
        crePublishReceiver.onReport("", report);
    }

    function testDoublePublishReverts() public {
        console2.log("[TEST] testDoublePublishReverts");
        console2.log("[ARRANGE] Publish draft once successfully");
        LiquidityVaultFactory vaultFactory = new LiquidityVaultFactory(address(0));
        vm.prank(draftClaimManager.owner());
        draftClaimManager.setLiquidityVaultFactory(address(vaultFactory));
        marketFactory.setDraftClaimManager(address(draftClaimManager));

        token.mint(creator, 100 ether);
        vm.prank(creator);
        token.approve(address(draftClaimManager), 100 ether);

        bytes32 draftId = _proposeDraftWithSeed(address(token), 50 ether);
        _claimAndSeed(draftId);
        _publishDraft(draftId);

        IMarketFactoryFromDraft.DraftPublishParams memory params = IMarketFactoryFromDraft.DraftPublishParams({
            question: "Will X happen?",
            marketType: 0,
            outcomes: _strs("Yes", "No"),
            timelineWindows: new uint48[](0),
            resolveTime: uint48(block.timestamp + 86400),
            tradingOpen: 0,
            tradingClose: uint48(block.timestamp + 86400)
        });
        bytes32 paramsHash = keccak256(
            abi.encode(
                params.question,
                params.marketType,
                keccak256(abi.encode(params.outcomes)),
                keccak256(abi.encode(params.timelineWindows)),
                params.resolveTime,
                params.tradingOpen,
                params.tradingClose
            )
        );
        bytes32 publishDigest = crePublishReceiver.digestPublishFromDraft(draftId, paramsHash, creator);
        (uint8 pv, bytes32 pr, bytes32 ps) = vm.sign(creatorPk, publishDigest);
        bytes memory report = abi.encode(draftId, creator, params, abi.encodePacked(pr, ps, pv));

        console2.log("[ASSERT] Second publish attempt reverts because draft is no longer claimable");
        vm.expectRevert(CREPublishReceiver.DraftNotClaimed.selector);
        vm.prank(forwarder);
        crePublishReceiver.onReport("", report);
    }

    function testPolicyMinCreatorSeedEnforcedOnPublish() public {
        console2.log("[TEST] testPolicyMinCreatorSeedEnforcedOnPublish");
        console2.log("[ARRANGE] Policy min seed = 100 ether, draft min seed only 50 ether");
        LiquidityVaultFactory vaultFactory = new LiquidityVaultFactory(address(0));
        vm.prank(draftClaimManager.owner());
        draftClaimManager.setLiquidityVaultFactory(address(vaultFactory));
        marketFactory.setDraftClaimManager(address(draftClaimManager));

        marketPolicy.setMinCreatorSeed(100 ether);
        token.mint(creator, 100 ether);
        vm.prank(creator);
        token.approve(address(draftClaimManager), 100 ether);

        bytes32 draftId = _proposeDraftWithSeed(address(token), 50 ether); // below policy minimum
        _claimAndSeed(draftId);

        IMarketFactoryFromDraft.DraftPublishParams memory params = IMarketFactoryFromDraft.DraftPublishParams({
            question: "Will X happen?",
            marketType: 0,
            outcomes: _strs("Yes", "No"),
            timelineWindows: new uint48[](0),
            resolveTime: uint48(block.timestamp + 86400),
            tradingOpen: 0,
            tradingClose: uint48(block.timestamp + 86400)
        });
        bytes32 paramsHash = keccak256(
            abi.encode(
                params.question,
                params.marketType,
                keccak256(abi.encode(params.outcomes)),
                keccak256(abi.encode(params.timelineWindows)),
                params.resolveTime,
                params.tradingOpen,
                params.tradingClose
            )
        );
        bytes32 publishDigest = crePublishReceiver.digestPublishFromDraft(draftId, paramsHash, creator);
        (uint8 pv, bytes32 pr, bytes32 ps) = vm.sign(creatorPk, publishDigest);
        bytes memory report = abi.encode(draftId, creator, params, abi.encodePacked(pr, ps, pv));
        console2.log("[ASSERT] Publish report reverts with SeedTooLow");
        vm.prank(forwarder);
        vm.expectRevert(MarketPolicy.SeedTooLow.selector);
        crePublishReceiver.onReport("", report);
    }

    function _proposeDraft() internal returns (bytes32 draftId) {
        bytes32 questionHash = keccak256("Will X happen?");
        bytes32 outcomesHash = keccak256(abi.encode(_strs("Yes", "No")));
        bytes32 resolveSpecHash = keccak256("resolver-v1");
        vm.prank(address(this));
        draftId = draftBoard.proposeDraft(
            questionHash,
            "ipfs://QmQuestion",
            MarketDraftBoard.MarketType.Binary,
            outcomesHash,
            "ipfs://QmOutcomes",
            resolveSpecHash,
            0,
            uint48(block.timestamp + 86400),
            uint48(block.timestamp + 86400),
            address(0),
            0
        );
        assertEq(uint8(draftBoard.getStatus(draftId)), uint8(MarketDraftBoard.DraftStatus.Proposed));
    }

    function _proposeDraftWithSeed(address settlementAsset, uint256 minSeed) internal returns (bytes32 draftId) {
        bytes32 questionHash = keccak256("Will X happen?");
        bytes32 outcomesHash = keccak256(abi.encode(_strs("Yes", "No")));
        bytes32 resolveSpecHash = keccak256("resolver-v1");
        vm.prank(address(this));
        draftId = draftBoard.proposeDraft(
            questionHash,
            "ipfs://QmQuestion",
            MarketDraftBoard.MarketType.Binary,
            outcomesHash,
            "ipfs://QmOutcomes",
            resolveSpecHash,
            0,
            uint48(block.timestamp + 86400),
            uint48(block.timestamp + 86400),
            settlementAsset,
            minSeed
        );
        assertEq(uint8(draftBoard.getStatus(draftId)), uint8(MarketDraftBoard.DraftStatus.Proposed));
    }

    function _claimAndSeed(bytes32 draftId) internal {
        bytes32 claimDigest = draftClaimManager.digestClaimAndSeed(draftId, address(token), 50 ether, 0, creator);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(creatorPk, claimDigest);
        vm.prank(creator);
        draftClaimManager.claimAndSeed(draftId, address(token), 50 ether, 0, abi.encodePacked(r, s, v));
        assertEq(uint8(draftBoard.getStatus(draftId)), uint8(MarketDraftBoard.DraftStatus.Claimed));
        assertEq(draftClaimManager.getClaimer(draftId), creator);
    }

    function _claimDraft(bytes32 draftId) internal {
        bytes32 claimDigest = draftClaimManager.digestClaimDraft(draftId, 0, bytes32(0), 0, creator);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(creatorPk, claimDigest);
        vm.prank(creator);
        draftClaimManager.claimDraft(draftId, 0, bytes32(0), 0, abi.encodePacked(r, s, v));
        assertEq(uint8(draftBoard.getStatus(draftId)), uint8(MarketDraftBoard.DraftStatus.Claimed));
        assertEq(draftClaimManager.getClaimer(draftId), creator);
    }

    function _publishDraft(bytes32 draftId) internal {
        IMarketFactoryFromDraft.DraftPublishParams memory params = IMarketFactoryFromDraft.DraftPublishParams({
            question: "Will X happen?",
            marketType: 0,
            outcomes: _strs("Yes", "No"),
            timelineWindows: new uint48[](0),
            resolveTime: uint48(block.timestamp + 86400),
            tradingOpen: 0,
            tradingClose: uint48(block.timestamp + 86400)
        });
        bytes32 paramsHash = keccak256(
            abi.encode(
                params.question,
                params.marketType,
                keccak256(abi.encode(params.outcomes)),
                keccak256(abi.encode(params.timelineWindows)),
                params.resolveTime,
                params.tradingOpen,
                params.tradingClose
            )
        );
        bytes32 publishDigest = crePublishReceiver.digestPublishFromDraft(draftId, paramsHash, creator);
        (uint8 pv, bytes32 pr, bytes32 ps) = vm.sign(creatorPk, publishDigest);
        bytes memory report = abi.encode(draftId, creator, params, abi.encodePacked(pr, ps, pv));
        vm.prank(forwarder);
        crePublishReceiver.onReport("", report);
    }

    function _strs(string memory a, string memory b) internal pure returns (string[] memory) {
        string[] memory s = new string[](2);
        s[0] = a;
        s[1] = b;
        return s;
    }
}

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
}
