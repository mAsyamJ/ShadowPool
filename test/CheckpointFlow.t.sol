// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {ShadowTypes} from "../src/libs/ShadowTypes.sol";
import {Hashing} from "../src/libs/Hashing.sol";
import {CollateralVault} from "../src/execution/CollateralVault.sol";
import {ExecutionLedger} from "../src/execution/ExecutionLedger.sol";
import {ChannelSettlement} from "../src/execution/ChannelSettlement.sol";

contract CheckpointFlowTest is Test {
    ERC20Mock token;
    CollateralVault vault;
    ExecutionLedger ledger;
    ChannelSettlement channel;

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
        ledger = new ExecutionLedger(address(0));
        channel = new ChannelSettlement(address(vault), address(ledger), operator);

        vault.setChannelSettlement(address(channel));
        ledger.setChannelSettlement(address(channel));

        token.approve(address(vault), 1000 ether);
        vault.deposit(100 ether);
        vm.prank(user);
        token.approve(address(vault), 100 ether);
        vm.prank(user);
        vault.deposit(10 ether);
    }

    function _makeCheckpoint(uint64 nonce, bytes32 deltasHash) internal view returns (ShadowTypes.Checkpoint memory) {
        return ShadowTypes.Checkpoint({
            marketId: marketId,
            sessionId: sessionId,
            nonce: nonce,
            validAfter: 0,
            validBefore: 0,
            lastTradeAt: 0,
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

    function testRejectsBadDeltasHash() public {
        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](1);
        deltas[0] = ShadowTypes.Delta({
            user: user,
            outcomeIndex: 0,
            sharesDelta: 10,
            cashDelta: -100
        });
        bytes32 wrongHash = keccak256("wrong");
        ShadowTypes.Checkpoint memory cp = _makeCheckpoint(1, wrongHash);

        bytes memory opSig = _signCheckpoint(cp, operatorPk);
        bytes[] memory userSigs = _toBytesArray(_signCheckpoint(cp, userPk));
        vm.expectRevert();
        channel.submitCheckpoint(
            cp,
            deltas,
            opSig,
            _toArray(user),
            userSigs
        );
    }

    function testRejectsNonIncreasingNonce() public {
        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](1);
        deltas[0] = ShadowTypes.Delta({
            user: user,
            outcomeIndex: 0,
            sharesDelta: 10,
            cashDelta: -1000
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
        vm.warp(block.timestamp + 31 minutes);
        channel.finalizeCheckpoint(marketId, sessionId, deltas);

        // Now latestNonce is 1. Submitting nonce 1 again should revert.
        bytes memory opSig2 = _signCheckpoint(cp, operatorPk);
        bytes[] memory userSigs2 = _toBytesArray(_signCheckpoint(cp, userPk));
        vm.expectRevert();
        channel.submitCheckpoint(cp, deltas, opSig2, _toArray(user), userSigs2);
    }

    function testRejectsInvalidOperatorSig() public {
        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](1);
        deltas[0] = ShadowTypes.Delta({
            user: user,
            outcomeIndex: 0,
            sharesDelta: 10,
            cashDelta: -100
        });
        bytes32 dHash = Hashing.hashDeltas(deltas);
        ShadowTypes.Checkpoint memory cp = _makeCheckpoint(1, dHash);

        bytes memory wrongOpSig = _signCheckpoint(cp, userPk);
        bytes[] memory userSigs = _toBytesArray(_signCheckpoint(cp, userPk));
        vm.expectRevert();
        channel.submitCheckpoint(cp, deltas, wrongOpSig, _toArray(user), userSigs);
    }

    function testRejectsInvalidUserSig() public {
        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](1);
        deltas[0] = ShadowTypes.Delta({
            user: user,
            outcomeIndex: 0,
            sharesDelta: 10,
            cashDelta: -100
        });
        bytes32 dHash = Hashing.hashDeltas(deltas);
        ShadowTypes.Checkpoint memory cp = _makeCheckpoint(1, dHash);

        bytes memory opSig = _signCheckpoint(cp, operatorPk);
        bytes[] memory wrongUserSigs = _toBytesArray(_signCheckpoint(cp, operatorPk));
        vm.expectRevert();
        channel.submitCheckpoint(cp, deltas, opSig, _toArray(user), wrongUserSigs);
    }

    function testChallengeBeforeDeadlineSucceeds() public {
        ShadowTypes.Delta[] memory deltas1 = new ShadowTypes.Delta[](1);
        deltas1[0] = ShadowTypes.Delta({
            user: user,
            outcomeIndex: 0,
            sharesDelta: 10,
            cashDelta: -100
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

        ShadowTypes.Delta[] memory deltas2 = new ShadowTypes.Delta[](1);
        deltas2[0] = ShadowTypes.Delta({
            user: user,
            outcomeIndex: 0,
            sharesDelta: 15,
            cashDelta: -150
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

        assertEq(channel.latestNonce(marketId, sessionId), 0);
        bytes32 key = keccak256(abi.encode(marketId, sessionId));
        (uint64 pendingNonce, uint64 deadline,, bytes32 stateHash, bytes32 deltasHash, bytes32 riskHash, bool exists) =
            channel.pendingByKey(key);
        assertTrue(exists);
        assertEq(pendingNonce, 6);
    }

    function testFinalizeBeforeDeadlineFails() public {
        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](1);
        deltas[0] = ShadowTypes.Delta({
            user: user,
            outcomeIndex: 0,
            sharesDelta: 10,
            cashDelta: -100
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

        vm.expectRevert();
        channel.finalizeCheckpoint(marketId, sessionId, deltas);
    }

    function testFinalizeAfterDeadlineSucceeds() public {
        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](1);
        deltas[0] = ShadowTypes.Delta({
            user: user,
            outcomeIndex: 0,
            sharesDelta: 10,
            cashDelta: -1000
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

        vm.warp(block.timestamp + 31 minutes);
        channel.finalizeCheckpoint(marketId, sessionId, deltas);

        assertEq(ledger.positionOf(user, marketId, 0), 10);
        assertEq(vault.freeBalance(user), 10 ether - 1000);
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
