// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {ShadowTypes} from "../src/libs/ShadowTypes.sol";
import {Hashing} from "../src/libs/Hashing.sol";
import {CollateralVault} from "../src/execution/CollateralVault.sol";
import {OutcomeToken1155} from "../src/execution/OutcomeToken1155.sol";
import {ChannelSettlement} from "../src/execution/ChannelSettlement.sol";
import {MarketRegistry} from "../src/core/MarketRegistry.sol";
import {Errors} from "../src/utils/Errors.sol";
import {FeeManager} from "../src/fees/FeeManager.sol";

/// @title EscrowFlowTest
/// @notice Tests for escrow-safe reserve-on-submit, release-on-finalize.
contract EscrowFlowTest is Test {
    ERC20Mock token;
    CollateralVault vault;
    OutcomeToken1155 outcomeToken;
    ChannelSettlement channel;
    MarketRegistry marketRegistry;

    uint256 operatorPk = 0xA11CE;
    address operator;
    uint256 userPk = 0xB0B;
    address user;

    uint256 marketId = 1;
    bytes32 sessionId = keccak256("session-1");

    function setUp() public {
        operator = vm.addr(operatorPk);
        user = vm.addr(userPk);

        token = new ERC20Mock();
        token.mint(address(this), 1000 ether);
        token.mint(user, 100 ether);

        vault = new CollateralVault(address(token), address(0));
        outcomeToken = new OutcomeToken1155("https://api.retropick.xyz/outcome/{id}.json");
        channel = new ChannelSettlement(address(vault), address(0), operator);
        marketRegistry = new MarketRegistry(address(vault), address(0));

        vm.startPrank(channel.owner());
        channel.setOutcomeToken(address(outcomeToken));
        channel.setMarketRegistry(address(marketRegistry));
        vm.stopPrank();
        vm.prank(outcomeToken.owner());
        outcomeToken.setChannelSettlement(address(channel));
        vm.prank(outcomeToken.owner());
        outcomeToken.setMarketRegistry(address(marketRegistry));
        vm.prank(marketRegistry.owner());
        marketRegistry.setOutcomeToken(address(outcomeToken));
        vm.prank(marketRegistry.owner());
        marketRegistry.setMarketFactory(address(this));
        vm.prank(marketRegistry.owner());
        marketRegistry.createMarketForWithExpiryAndAsset("Test", address(this), uint48(block.timestamp + 86400), address(token));

        vault.setChannelSettlement(address(channel));

        token.approve(address(vault), 1000 ether);
        vault.deposit(100 ether);
        vm.prank(user);
        token.approve(address(vault), 100 ether);
        vm.prank(user);
        vault.deposit(100); // user has 100 tokens
    }

    function _makeCheckpoint(uint64 nonce, bytes32 deltasHash) internal view returns (ShadowTypes.Checkpoint memory) {
        return ShadowTypes.Checkpoint({
            marketId: marketId,
            sessionId: sessionId,
            nonce: nonce,
            validAfter: 0,
            validBefore: 0,
            lastTradeAt: uint48(block.timestamp),
            stateHash: keccak256("state"),
            deltasHash: deltasHash,
            riskHash: bytes32(0)
        });
    }

    function _signCheckpoint(ShadowTypes.Checkpoint memory cp, uint256 pk) internal view returns (bytes memory) {
        bytes32 digest = channel.digestCheckpoint(cp);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest);
        return abi.encodePacked(r, s, v);
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

    function test_Escrow_WithdrawBlockedByReserve() public {
        console2.log("[TEST] test_Escrow_WithdrawBlockedByReserve");
        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](1);
        deltas[0] = ShadowTypes.Delta({
            user: user,
            outcomeIndex: 0,
            sharesDelta: 10,
            cashDelta: -60
        });
        bytes32 dHash = Hashing.hashDeltas(deltas);
        ShadowTypes.Checkpoint memory cp = _makeCheckpoint(1, dHash);

        channel.submitCheckpoint(
            cp,
            deltas,
            _signCheckpoint(cp, operatorPk),
            _toArray(user),
            _toBytesArray(_signCheckpoint(cp, userPk))
        );

        assertEq(vault.reservedBalance(user), 60);
        assertEq(vault.availableBalance(user), 40);

        vm.prank(user);
        vm.expectRevert(Errors.InsufficientAvailableBalance.selector);
        vault.withdraw(50);
    }

    function test_Escrow_ReserveReleasedOnFinalize() public {
        console2.log("[TEST] test_Escrow_ReserveReleasedOnFinalize");
        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](1);
        deltas[0] = ShadowTypes.Delta({
            user: user,
            outcomeIndex: 0,
            sharesDelta: 10,
            cashDelta: -60
        });
        bytes32 dHash = Hashing.hashDeltas(deltas);
        ShadowTypes.Checkpoint memory cp = _makeCheckpoint(1, dHash);

        channel.submitCheckpoint(
            cp,
            deltas,
            _signCheckpoint(cp, operatorPk),
            _toArray(user),
            _toBytesArray(_signCheckpoint(cp, userPk))
        );

        assertEq(vault.reservedBalance(user), 60);

        vm.warp(block.timestamp + 31 minutes);
        channel.finalizeCheckpoint(marketId, sessionId, deltas);

        assertEq(vault.reservedBalance(user), 0);
        assertEq(vault.availableBalance(user), 40);
        vm.prank(user);
        vault.withdraw(40);
    }

    function test_Escrow_ReserveReplacedOnNewCheckpoint() public {
        console2.log("[TEST] test_Escrow_ReserveReplacedOnNewCheckpoint");
        ShadowTypes.Delta[] memory deltas1 = new ShadowTypes.Delta[](1);
        deltas1[0] = ShadowTypes.Delta({
            user: user,
            outcomeIndex: 0,
            sharesDelta: 10,
            cashDelta: -60
        });
        bytes32 dHash1 = Hashing.hashDeltas(deltas1);
        ShadowTypes.Checkpoint memory cp1 = _makeCheckpoint(5, dHash1);

        channel.submitCheckpoint(
            cp1,
            deltas1,
            _signCheckpoint(cp1, operatorPk),
            _toArray(user),
            _toBytesArray(_signCheckpoint(cp1, userPk))
        );

        assertEq(vault.reservedBalance(user), 60);

        ShadowTypes.Delta[] memory deltas2 = new ShadowTypes.Delta[](1);
        deltas2[0] = ShadowTypes.Delta({
            user: user,
            outcomeIndex: 0,
            sharesDelta: 15,
            cashDelta: -20
        });
        bytes32 dHash2 = Hashing.hashDeltas(deltas2);
        ShadowTypes.Checkpoint memory cp2 = _makeCheckpoint(6, dHash2);

        channel.challengeCheckpoint(
            cp2,
            deltas2,
            _signCheckpoint(cp2, operatorPk),
            _toArray(user),
            _toBytesArray(_signCheckpoint(cp2, userPk))
        );

        assertEq(vault.reservedBalance(user), 20);
    }

    function test_Escrow_CancelPendingReleasesReserve() public {
        console2.log("[TEST] test_Escrow_CancelPendingReleasesReserve");
        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](1);
        deltas[0] = ShadowTypes.Delta({
            user: user,
            outcomeIndex: 0,
            sharesDelta: 10,
            cashDelta: -60
        });
        bytes32 dHash = Hashing.hashDeltas(deltas);
        ShadowTypes.Checkpoint memory cp = _makeCheckpoint(1, dHash);

        channel.submitCheckpoint(
            cp,
            deltas,
            _signCheckpoint(cp, operatorPk),
            _toArray(user),
            _toBytesArray(_signCheckpoint(cp, userPk))
        );

        assertEq(vault.reservedBalance(user), 60);

        vm.warp(block.timestamp + channel.CANCEL_DELAY() + 1);
        channel.cancelPendingCheckpoint(marketId, sessionId);

        assertEq(vault.reservedBalance(user), 0);
        bytes32 key = keccak256(abi.encode(marketId, sessionId));
        (, , , , , , bool exists, , ) = channel.pendingByKey(key);
        assertFalse(exists);
    }

    function test_Escrow_CancelTooEarlyReverts() public {
        console2.log("[TEST] test_Escrow_CancelTooEarlyReverts");
        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](1);
        deltas[0] = ShadowTypes.Delta({
            user: user,
            outcomeIndex: 0,
            sharesDelta: 10,
            cashDelta: -60
        });
        bytes32 dHash = Hashing.hashDeltas(deltas);
        ShadowTypes.Checkpoint memory cp = _makeCheckpoint(1, dHash);

        channel.submitCheckpoint(
            cp,
            deltas,
            _signCheckpoint(cp, operatorPk),
            _toArray(user),
            _toBytesArray(_signCheckpoint(cp, userPk))
        );

        vm.warp(block.timestamp + 1 hours);
        vm.expectRevert(Errors.CancelTooEarly.selector);
        channel.cancelPendingCheckpoint(marketId, sessionId);
    }

    function test_Escrow_ReserveComputationMatchesFeeSplit() public {
        console2.log("[TEST] test_Escrow_ReserveComputationMatchesFeeSplit");
        vm.prank(user);
        vault.deposit(200);

        uint256 user2Pk = 0x999;
        address user2 = vm.addr(user2Pk);
        token.mint(user2, 100 ether);
        vm.prank(user2);
        token.approve(address(vault), 100 ether);
        vm.prank(user2);
        vault.deposit(200);

        FeeManager feeManager = new FeeManager(100);
        vm.prank(channel.owner());
        channel.setFeeManager(address(feeManager));

        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](2);
        deltas[0] = ShadowTypes.Delta({
            user: user,
            outcomeIndex: 0,
            sharesDelta: 10,
            cashDelta: -100
        });
        deltas[1] = ShadowTypes.Delta({
            user: user2,
            outcomeIndex: 1,
            sharesDelta: -10,
            cashDelta: 95
        });
        bytes32 dHash = Hashing.hashDeltas(deltas);
        ShadowTypes.Checkpoint memory cp = _makeCheckpoint(1, dHash);

        channel.submitCheckpoint(
            cp,
            deltas,
            _signCheckpoint(cp, operatorPk),
            _toArray2(user, user2),
            _toBytesArray2(_signCheckpoint(cp, userPk), _signCheckpoint(cp, user2Pk))
        );

        assertEq(vault.reservedBalance(user), 100);
        assertEq(vault.reservedBalance(user2), 0);
    }

    function _toArray2(address a, address b) internal pure returns (address[] memory) {
        address[] memory arr = new address[](2);
        arr[0] = a;
        arr[1] = b;
        return arr;
    }

    function _toBytesArray2(bytes memory b1, bytes memory b2) internal pure returns (bytes[] memory) {
        bytes[] memory arr = new bytes[](2);
        arr[0] = b1;
        arr[1] = b2;
        return arr;
    }
}
