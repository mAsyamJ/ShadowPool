// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @title E2EDeployTestnet
/// @notice End-to-end test mirroring DeployTestnet.s.sol topology and CurrentSmartContract.md production path.
/// @dev Validates: Curated draft -> claimAndSeed -> publish -> checkpoint settlement -> oracle resolution -> redeem.
///      Uses the same contract wiring as script/DeployTestnet.s.sol (MarketRegistry + ChannelSettlement lane).

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {ShadowTypes} from "../src/libs/ShadowTypes.sol";
import {Hashing} from "../src/libs/Hashing.sol";

import {OutcomeToken1155} from "../src/execution/OutcomeToken1155.sol";
import {MarketRiskManager} from "../src/execution/MarketRiskManager.sol";
import {ChannelSettlement} from "../src/execution/ChannelSettlement.sol";
import {MultiAssetVault} from "../src/execution/MultiAssetVault.sol";
import {CollateralVault} from "../src/execution/CollateralVault.sol";
import {MarketRegistry} from "../src/core/MarketRegistry.sol";

import {FeeManager} from "../src/fees/FeeManager.sol";
import {FeePool} from "../src/fees/FeePool.sol";
import {TreasuryPool} from "../src/fees/TreasuryPool.sol";

import {ReportValidator} from "../src/oracle/ReportValidator.sol";
import {CREReceiver} from "../src/oracle/CREReceiver.sol";
import {OracleCoordinator} from "../src/oracle/OracleCoordinator.sol";
import {SettlementRouter} from "../src/core/SettlementRouter.sol";

import {MarketPolicy} from "../src/curation/MarketPolicy.sol";
import {MarketDraftBoard} from "../src/curation/MarketDraftBoard.sol";
import {DraftClaimManager} from "../src/curation/DraftClaimManager.sol";
import {LiquidityVaultFactory} from "../src/curation/LiquidityVaultFactory.sol";
import {CREPublishReceiver} from "../src/curation/CREPublishReceiver.sol";
import {MarketFactory} from "../src/core/MarketFactory.sol";

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

contract E2EDeployTestnetTest is Test {
    // ---- Deployed stack (mirrors DeployTestnet.s.sol, V3 with OutcomeToken) ----
    OutcomeToken1155 outcomeToken;
    MarketRiskManager riskManager;
    ChannelSettlement channelSettlement;
    MultiAssetVault multiAssetVault;
    CollateralVault collateralVault;
    MarketRegistry marketRegistry;
    FeeManager feeManager;
    FeePool feePool;
    TreasuryPool treasuryPool;
    ReportValidator reportValidator;
    CREReceiver creReceiver;
    OracleCoordinator oracleCoordinator;
    SettlementRouter settlementRouter;
    MarketPolicy marketPolicy;
    MarketDraftBoard draftBoard;
    DraftClaimManager draftClaimManager;
    LiquidityVaultFactory liquidityVaultFactory;
    CREPublishReceiver crePublishReceiver;
    MarketFactory marketFactory;

    ERC20Mock settlementToken;

    address forwarder = address(0xF0);
    address operator;
    uint256 operatorPk = 0xA11CE;
    address creator;
    uint256 creatorPk = 0xBEEF;
    address trader;
    uint256 traderPk = 0xC0DE;

    uint16 constant MIN_CONFIDENCE = 8000;
    uint16 constant PROTOCOL_FEE_BPS = 100;
    uint16 constant LP_FEE_SHARE_BPS = 2000;
    uint16 constant CREATOR_FEE_SHARE_BPS = 1000;

    bytes32 sessionId = keccak256("e2e-session");

    function setUp() public {
        vm.warp(1000);

        operator = vm.addr(operatorPk);
        creator = vm.addr(creatorPk);
        trader = vm.addr(traderPk);

        settlementToken = new ERC20Mock();
        settlementToken.mint(address(this), 10_000 ether);
        settlementToken.mint(creator, 1000 ether);
        settlementToken.mint(trader, 1000 ether);

        _deployFullStack();
    }

    /// @notice Deploys the full production stack as in DeployTestnet.s.sol (V3 with OutcomeToken)
    function _deployFullStack() internal {
        // 1) V3 Execution lane: OutcomeToken1155 + MarketRiskManager
        outcomeToken = new OutcomeToken1155("https://api.retropick.xyz/outcome/{id}.json");
        riskManager = new MarketRiskManager();
        multiAssetVault = new MultiAssetVault(address(0));
        collateralVault = new CollateralVault(address(settlementToken), address(0));
        channelSettlement = new ChannelSettlement(address(collateralVault), address(0), operator);
        marketRegistry = new MarketRegistry(address(collateralVault), address(0));

        outcomeToken.setChannelSettlement(address(channelSettlement));
        outcomeToken.setMarketRegistry(address(marketRegistry));
        riskManager.setChannelSettlement(address(channelSettlement));
        channelSettlement.setOutcomeToken(address(outcomeToken));
        channelSettlement.setRiskManager(address(riskManager));
        marketRegistry.setOutcomeToken(address(outcomeToken));
        multiAssetVault.setChannelSettlement(address(channelSettlement));
        multiAssetVault.setMarketRegistry(address(marketRegistry));
        collateralVault.setChannelSettlement(address(channelSettlement));
        collateralVault.setMarketRegistry(address(marketRegistry));
        channelSettlement.setMarketRegistry(address(marketRegistry));
        channelSettlement.setMultiAssetVault(address(multiAssetVault));
        marketRegistry.setMultiAssetVault(address(multiAssetVault));
        marketRegistry.setDefaultSettlementAsset(address(settlementToken));

        // 2) Fees
        feeManager = new FeeManager(PROTOCOL_FEE_BPS);
        feePool = new FeePool();
        treasuryPool = new TreasuryPool();

        feeManager.setLpFeeShareBps(LP_FEE_SHARE_BPS);
        feeManager.setCreatorFeeShareBps(CREATOR_FEE_SHARE_BPS);
        feePool.setFeeCollector(address(channelSettlement));
        feePool.setTreasuryPool(address(treasuryPool));
        channelSettlement.setFeeManager(address(feeManager));
        channelSettlement.setFeePool(address(feePool));

        // 3) Oracle and routing
        reportValidator = new ReportValidator(MIN_CONFIDENCE);
        oracleCoordinator = new OracleCoordinator();
        settlementRouter = new SettlementRouter();
        creReceiver = new CREReceiver(forwarder, address(oracleCoordinator));

        oracleCoordinator.setCreReceiver(address(creReceiver));
        oracleCoordinator.setSettlementRouter(address(settlementRouter));
        oracleCoordinator.setReportValidator(address(reportValidator));

        settlementRouter.setOracleCoordinator(address(oracleCoordinator));
        settlementRouter.setChannelSettlement(address(channelSettlement));
        settlementRouter.setUseReceiverAllowlist(true);
        settlementRouter.setMarketReceiverApproved(address(marketRegistry), true);
        marketRegistry.setSettlementRouter(address(settlementRouter));

        // 4) Curated lane
        marketPolicy = new MarketPolicy();
        draftBoard = new MarketDraftBoard();
        draftClaimManager = new DraftClaimManager(address(draftBoard));
        liquidityVaultFactory = new LiquidityVaultFactory(address(channelSettlement));
        marketFactory = new MarketFactory(forwarder, address(marketRegistry));
        crePublishReceiver = new CREPublishReceiver(
            forwarder,
            address(draftBoard),
            address(draftClaimManager),
            address(marketPolicy),
            address(marketFactory)
        );

        draftBoard.setDraftClaimManager(address(draftClaimManager));
        draftBoard.grantPublishCaller(address(marketFactory));
        draftBoard.grantRole(draftBoard.AI_ORACLE_ROLE(), address(this));
        draftClaimManager.setLiquidityVaultFactory(address(liquidityVaultFactory));

        marketFactory.setMarketRegistry(address(marketRegistry));
        marketFactory.setDraftBoard(address(draftBoard));
        marketFactory.setDraftClaimManager(address(draftClaimManager));
        marketFactory.setMarketPolicy(address(marketPolicy));
        marketFactory.setRiskManager(address(riskManager));
        marketFactory.setPublishReceiverApproved(address(crePublishReceiver), true);
        riskManager.setMarketFactory(address(marketFactory));

        marketRegistry.setMarketFactory(address(marketFactory));
    }

    // -------------------------------------------------------------------------
    // E2E: Full production path (CurrentSmartContract.md §13)
    // -------------------------------------------------------------------------

    function testE2E_CuratedDraftClaimPublishCheckpointResolveRedeem() public {
        console2.log("[E2E] Curated draft -> claimAndSeed -> publish -> checkpoint -> resolve -> redeem");

        // ---- 1. Propose draft with settlement asset and min seed ----
        uint48 tradingClose = uint48(block.timestamp + 86400);
        uint48 resolveTime = uint48(block.timestamp + 86400);
        bytes32 draftId = _proposeDraftWithSeed(address(settlementToken), 50 ether);

        assertEq(uint8(draftBoard.getStatus(draftId)), uint8(MarketDraftBoard.DraftStatus.Proposed));

        // ---- 2. claimAndSeed (creator seeds liquidity) ----
        vm.prank(creator);
        settlementToken.approve(address(draftClaimManager), 100 ether);
        _claimAndSeed(draftId, 50 ether);

        assertEq(uint8(draftBoard.getStatus(draftId)), uint8(MarketDraftBoard.DraftStatus.Claimed));
        assertTrue(draftClaimManager.getLiquidityVault(draftId) != address(0));

        // ---- 3. Publish via CREPublishReceiver ----
        _publishDraft(draftId, tradingClose, resolveTime);

        uint256 marketId = 0;
        assertEq(uint8(draftBoard.getStatus(draftId)), uint8(MarketDraftBoard.DraftStatus.Published));
        assertEq(marketFactory.draftIdByMarketId(marketId), draftId);
        assertEq(marketRegistry.getCreator(marketId), creator);
        assertTrue(marketRegistry.liquidityVaultByMarketId(marketId) != address(0));

        // ---- 4. Trader deposits and checkpoint (trade: trader buys outcome 0) ----
        // When multiAssetVault is set (DeployTestnet topology), cash deltas use MAV; deposit there
        vm.prank(trader);
        settlementToken.approve(address(multiAssetVault), 1000 ether);
        vm.prank(trader);
        multiAssetVault.deposit(address(settlementToken), 100 ether);

        // Checkpoint: trader spends 1000 units of cash, gets 10 shares outcome 0
        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](1);
        deltas[0] = ShadowTypes.Delta({
            user: trader,
            outcomeIndex: 0,
            sharesDelta: 10,
            cashDelta: -1000
        });
        bytes32 dHash = Hashing.hashDeltas(deltas);
        ShadowTypes.Checkpoint memory cp = ShadowTypes.Checkpoint({
            marketId: marketId,
            sessionId: sessionId,
            nonce: 1,
            validAfter: 0,
            validBefore: 0,
            lastTradeAt: uint48(block.timestamp),
            stateHash: keccak256("state"),
            deltasHash: dHash,
            riskHash: bytes32(0)
        });

        channelSettlement.submitCheckpoint(
            cp,
            deltas,
            _signCheckpoint(cp, operatorPk),
            _toArray(trader),
            _toBytesArray(_signCheckpoint(cp, traderPk))
        );

        vm.warp(block.timestamp + 31 minutes);
        channelSettlement.finalizeCheckpoint(marketId, sessionId, deltas);

        uint256 tokenId = outcomeToken.id(marketId, 0);
        assertEq(outcomeToken.balanceOf(trader, tokenId), 10);
        assertEq(multiAssetVault.freeBalance(trader, address(settlementToken)), 100 ether - 1000);

        // ---- 5. Resolve via oracle path (CREReceiver -> Coordinator -> Router -> MarketRegistry) ----
        vm.warp(resolveTime + 1);
        marketRegistry.freeze(marketId);

        bytes memory outcomeReport =
            abi.encode(address(marketRegistry), marketId, uint8(0), uint16(9000));
        vm.prank(forwarder);
        creReceiver.onReport("", outcomeReport);

        MarketRegistry.Market memory m = marketRegistry.getMarket(marketId);
        assertTrue(m.settled);
        assertEq(m.confidence, 9000);
        assertEq(uint8(m.outcome), 0);

        // ---- 6. Redeem (trader has 10 winning shares) ----
        uint256 balBefore = settlementToken.balanceOf(trader);
        vm.prank(trader);
        uint256 payout = marketRegistry.redeem(marketId);
        assertEq(payout, 10);
        assertEq(settlementToken.balanceOf(trader), balBefore + 10);
    }

    // -------------------------------------------------------------------------
    // E2E: Escrow - withdraw blocked during checkpoint window, released on finalize
    // -------------------------------------------------------------------------

    function testE2E_EscrowWithdrawBlockedDuringCheckpointWindow() public {
        console2.log("[E2E] Escrow: submit reserves, withdraw reverts during window, finalize releases");

        vm.prank(address(marketFactory));
        marketRegistry.createMarketForWithExpiryAndAsset(
            "Escrow test market",
            creator,
            uint48(block.timestamp + 86400),
            address(settlementToken)
        );
        uint256 marketId = 0;

        vm.prank(trader);
        settlementToken.approve(address(multiAssetVault), 1000 ether);
        vm.prank(trader);
        multiAssetVault.deposit(address(settlementToken), 100 ether);

        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](1);
        deltas[0] = ShadowTypes.Delta({
            user: trader,
            outcomeIndex: 0,
            sharesDelta: 10,
            cashDelta: -50 ether
        });
        bytes32 dHash = Hashing.hashDeltas(deltas);
        ShadowTypes.Checkpoint memory cp = ShadowTypes.Checkpoint({
            marketId: marketId,
            sessionId: sessionId,
            nonce: 1,
            validAfter: 0,
            validBefore: 0,
            lastTradeAt: uint48(block.timestamp),
            stateHash: keccak256("state"),
            deltasHash: dHash,
            riskHash: bytes32(0)
        });

        channelSettlement.submitCheckpoint(
            cp,
            deltas,
            _signCheckpoint(cp, operatorPk),
            _toArray(trader),
            _toBytesArray(_signCheckpoint(cp, traderPk))
        );

        assertEq(multiAssetVault.reservedBalance(trader, address(settlementToken)), 50 ether);
        assertEq(multiAssetVault.availableBalance(trader, address(settlementToken)), 50 ether);

        vm.prank(trader);
        vm.expectRevert();
        multiAssetVault.withdraw(address(settlementToken), 60 ether);

        vm.warp(block.timestamp + 31 minutes);
        channelSettlement.finalizeCheckpoint(marketId, sessionId, deltas);

        assertEq(multiAssetVault.reservedBalance(trader, address(settlementToken)), 0);
        vm.prank(trader);
        multiAssetVault.withdraw(address(settlementToken), 50 ether);
    }

    // -------------------------------------------------------------------------
    // E2E: Session payload routing (checkpoint via CRE 0x03)
    // -------------------------------------------------------------------------

    function testE2E_CheckpointViaSessionPayload() public {
        console2.log("[E2E] Create market, submit checkpoint via session payload (0x03)");

        // Create market directly for this test (simpler than full curated path)
        vm.prank(address(marketFactory));
        marketRegistry.createMarketForWithExpiryAndAsset(
            "Direct market",
            address(this),
            uint48(block.timestamp + 86400),
            address(settlementToken)
        );
        uint256 marketId = 0;

        settlementToken.approve(address(multiAssetVault), 1000 ether);
        multiAssetVault.deposit(address(settlementToken), 100 ether);
        vm.prank(trader);
        settlementToken.approve(address(multiAssetVault), 1000 ether);
        vm.prank(trader);
        multiAssetVault.deposit(address(settlementToken), 100 ether);

        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](1);
        deltas[0] = ShadowTypes.Delta({
            user: trader,
            outcomeIndex: 0,
            sharesDelta: 10,
            cashDelta: -1000
        });
        bytes32 dHash = Hashing.hashDeltas(deltas);
        ShadowTypes.Checkpoint memory cp = ShadowTypes.Checkpoint({
            marketId: marketId,
            sessionId: sessionId,
            nonce: 1,
            validAfter: 0,
            validBefore: 0,
            lastTradeAt: uint48(block.timestamp),
            stateHash: keccak256("state"),
            deltasHash: dHash,
            riskHash: bytes32(0)
        });

        bytes memory payload = abi.encode(
            cp,
            deltas,
            _signCheckpoint(cp, operatorPk),
            _toArray(trader),
            _toBytesArray(_signCheckpoint(cp, traderPk))
        );

        // CRE sends 0x03 + payload -> CREReceiver routes to coordinator.submitSession
        bytes memory report = bytes.concat(bytes1(0x03), payload);
        vm.prank(forwarder);
        creReceiver.onReport("", report);

        vm.warp(block.timestamp + 31 minutes);
        channelSettlement.finalizeCheckpoint(marketId, sessionId, deltas);

        uint256 tid = outcomeToken.id(marketId, 0);
        assertEq(outcomeToken.balanceOf(trader, tid), 10);
    }

    // -------------------------------------------------------------------------
    // E2E: Oracle resolution path
    // -------------------------------------------------------------------------

    function testE2E_OracleResolvesMarketRegistry() public {
        console2.log("[E2E] Oracle resolution path: CRE -> CREReceiver -> Coordinator -> Router -> MarketRegistry");

        vm.prank(address(marketFactory));
        marketRegistry.createMarketForWithExpiryAndAsset(
            "Will X happen?",
            creator,
            uint48(block.timestamp + 86400),
            address(settlementToken)
        );
        uint256 marketId = 0;

        bytes memory outcomeReport =
            abi.encode(address(marketRegistry), marketId, uint8(1), uint16(9500));
        vm.prank(forwarder);
        creReceiver.onReport("", outcomeReport);

        MarketRegistry.Market memory m = marketRegistry.getMarket(marketId);
        assertTrue(m.settled);
        assertEq(m.confidence, 9500);
        assertEq(uint8(m.outcome), 1);
    }

    function testE2E_OracleResolutionBelowMinConfidenceReverts() public {
        vm.prank(address(marketFactory));
        marketRegistry.createMarketForWithExpiryAndAsset(
            "Will X happen?",
            creator,
            uint48(block.timestamp + 86400),
            address(settlementToken)
        );

        bytes memory outcomeReport =
            abi.encode(address(marketRegistry), 0, uint8(0), uint16(5000)); // 5000 < MIN_CONFIDENCE 8000
        vm.prank(forwarder);
        vm.expectRevert();
        creReceiver.onReport("", outcomeReport);
    }

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    function _proposeDraftWithSeed(address settlementAsset, uint256 minSeed) internal returns (bytes32 draftId) {
        bytes32 questionHash = keccak256("Will X happen?");
        bytes32 outcomesHash = keccak256(abi.encode(_strs("Yes", "No")));
        bytes32 resolveSpecHash = keccak256("resolver-v1");
        uint48 tClose = uint48(block.timestamp + 86400);
        uint48 tResolve = uint48(block.timestamp + 86400);

        draftId = draftBoard.proposeDraft(
            questionHash,
            "ipfs://QmQuestion",
            MarketDraftBoard.MarketType.Binary,
            outcomesHash,
            "ipfs://QmOutcomes",
            resolveSpecHash,
            0,
            tClose,
            tResolve,
            settlementAsset,
            minSeed
        );
    }

    function _claimAndSeed(bytes32 draftId, uint256 seedAmount) internal {
        bytes32 claimDigest =
            draftClaimManager.digestClaimAndSeed(draftId, address(settlementToken), seedAmount, 0, creator);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(creatorPk, claimDigest);
        vm.prank(creator);
        draftClaimManager.claimAndSeed(
            draftId,
            address(settlementToken),
            seedAmount,
            0,
            abi.encodePacked(r, s, v)
        );
    }

    function _publishDraft(bytes32 draftId, uint48 tradingClose, uint48 resolveTime) internal {
        IMarketFactoryFromDraft.DraftPublishParams memory params = IMarketFactoryFromDraft.DraftPublishParams({
            question: "Will X happen?",
            marketType: 0,
            outcomes: _strs("Yes", "No"),
            timelineWindows: new uint48[](0),
            resolveTime: resolveTime,
            tradingOpen: 0,
            tradingClose: tradingClose
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

    function _signCheckpoint(ShadowTypes.Checkpoint memory cp, uint256 pk) internal view returns (bytes memory) {
        bytes32 digest = channelSettlement.digestCheckpoint(cp);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest);
        return abi.encodePacked(r, s, v);
    }

    function _strs(string memory a, string memory b) internal pure returns (string[] memory) {
        string[] memory s = new string[](2);
        s[0] = a;
        s[1] = b;
        return s;
    }

    function _toArray(address a) internal pure returns (address[] memory) {
        address[] memory arr = new address[](1);
        arr[0] = a;
        return arr;
    }

    function _toBytesArray(bytes memory b) internal pure returns (bytes[] memory) {
        bytes[] memory arr = new bytes[](1);
        arr[0] = b;
        return arr;
    }
}
