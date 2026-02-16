// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {ShadowTypes} from "../src/libs/ShadowTypes.sol";
import {Hashing} from "../src/libs/Hashing.sol";
import {MarketRegistry} from "../src/core/MarketRegistry.sol";
import {ReportValidator} from "../src/oracle/ReportValidator.sol";
import {Treasury} from "../src/core/Treasury.sol";
import {CollateralVault} from "../src/execution/CollateralVault.sol";
import {ExecutionLedger} from "../src/execution/ExecutionLedger.sol";
import {ChannelSettlement} from "../src/execution/ChannelSettlement.sol";
import {SettlementRouter} from "../src/core/SettlementRouter.sol";
import {Errors} from "../src/utils/Errors.sol";

/// @title SecurityHardeningTest
/// @notice P0 security tests from refactor plan.
contract SecurityHardeningTest is Test {
    ERC20Mock token;
    MarketRegistry registry;
    ReportValidator reportValidator;
    Treasury treasury;
    CollateralVault vault;
    ExecutionLedger ledger;
    ChannelSettlement channel;
    SettlementRouter router;

    address owner = address(0x1);
    address attacker = address(0x666);
    address operator;
    uint256 operatorPk = 0xA11CE;
    uint256 userPk = 0xB0B;
    address user;

    uint256 marketId = 0;
    bytes32 sessionId = keccak256("session-1");

    function setUp() public {
        vm.startPrank(owner);
        operator = vm.addr(operatorPk);
        user = vm.addr(userPk);

        token = new ERC20Mock();
        token.mint(address(this), 1000 ether);
        token.mint(user, 100 ether);

        vault = new CollateralVault(address(token), address(0));
        ledger = new ExecutionLedger(address(0));
        channel = new ChannelSettlement(address(vault), address(ledger), operator);

        vault.setChannelSettlement(address(channel));
        ledger.setChannelSettlement(address(channel));

        registry = new MarketRegistry(address(vault), address(ledger));
        router = new SettlementRouter();
        router.setOracleCoordinator(owner);
        registry.setSettlementRouter(address(router));
        registry.setMarketFactory(owner);
        channel.setMarketRegistry(address(registry));

        reportValidator = new ReportValidator(8000);
        treasury = new Treasury(address(token));

        registry.createMarketWithExpiry("Will X happen?", uint48(block.timestamp + 86400));
        vault.setMarketRegistry(address(registry));
        vm.stopPrank();

        token.approve(address(vault), 1000 ether);
        vault.deposit(100 ether);
        vm.prank(user);
        token.approve(address(vault), 100 ether);
        vm.prank(user);
        vault.deposit(10 ether);
    }

    function testMarketRegistryResolveUnauthorizedReverts() public {
        vm.prank(attacker);
        vm.expectRevert(MarketRegistry.UnauthorizedRouter.selector);
        registry.resolve(marketId, 0, 9000);
    }

    function testReportValidatorSetMinConfidenceUnauthorizedReverts() public {
        vm.prank(attacker);
        vm.expectRevert();
        reportValidator.setMinConfidence(5000);
    }

    function testTreasurySetMarketApprovedUnauthorizedReverts() public {
        vm.prank(attacker);
        vm.expectRevert();
        treasury.setMarketApproved(address(0x1), true);
    }

    function testCheckpointWithUnsignedDeltaUserReverts() public {
        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](2);
        deltas[0] = ShadowTypes.Delta({user: user, outcomeIndex: 0, sharesDelta: 10, cashDelta: -100});
        deltas[1] = ShadowTypes.Delta({user: attacker, outcomeIndex: 0, sharesDelta: 5, cashDelta: -50});

        bytes32 dHash = Hashing.hashDeltas(deltas);
        ShadowTypes.Checkpoint memory cp = ShadowTypes.Checkpoint({
            marketId: marketId,
            sessionId: sessionId,
            nonce: 1,
            validAfter: 0,
            validBefore: 0,
            lastTradeAt: 0,
            stateHash: keccak256("state"),
            deltasHash: dHash,
            riskHash: bytes32(0)
        });

        bytes memory opSig = _signCheckpoint(cp, operatorPk);
        address[] memory users = new address[](1);
        users[0] = user;
        bytes[] memory userSigs = new bytes[](1);
        userSigs[0] = _signCheckpoint(cp, userPk);

        vm.expectRevert(Errors.DeltaUserNotSigned.selector);
        channel.submitCheckpoint(cp, deltas, opSig, users, userSigs);
    }

    function testFinalizeCheckpointAfterTradingCloseWithLastTradeAtReverts() public {
        vm.warp(500);
        registry.createMarketWithExpiry("Market with close", uint48(500 + 100));
        uint256 mkId = 1;

        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](1);
        deltas[0] = ShadowTypes.Delta({user: user, outcomeIndex: 0, sharesDelta: 10, cashDelta: -100});
        bytes32 dHash = Hashing.hashDeltas(deltas);

        ShadowTypes.Checkpoint memory cp = ShadowTypes.Checkpoint({
            marketId: mkId,
            sessionId: sessionId,
            nonce: 1,
            validAfter: 0,
            validBefore: 0,
            lastTradeAt: 700,
            stateHash: keccak256("state"),
            deltasHash: dHash,
            riskHash: bytes32(0)
        });

        address[] memory users = new address[](1);
        users[0] = user;
        bytes[] memory userSigs = new bytes[](1);
        userSigs[0] = _signCheckpoint(cp, userPk);

        channel.submitCheckpoint(cp, deltas, _signCheckpoint(cp, operatorPk), users, userSigs);
        vm.warp(block.timestamp + 31 minutes);

        vm.expectRevert(Errors.CheckpointAfterTradingClose.selector);
        channel.finalizeCheckpoint(mkId, sessionId, deltas);
    }

    function _signCheckpoint(ShadowTypes.Checkpoint memory cp, uint256 pk) internal view returns (bytes memory) {
        bytes32 digest = channel.digestCheckpoint(cp);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest);
        return abi.encodePacked(r, s, v);
    }
}
