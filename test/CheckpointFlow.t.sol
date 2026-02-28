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

contract CheckpointFlowTest is Test {
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
        vault.deposit(10 ether);
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

    function testRejectsBadDeltasHash() public {
        console2.log("[TEST] testRejectsBadDeltasHash");
        console2.log("[ARRANGE] Create checkpoint with deltas payload but intentionally wrong deltasHash");
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
        console2.log("[ASSERT] submitCheckpoint reverts when checkpoint hash does not match payload");
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
        console2.log("[TEST] testRejectsNonIncreasingNonce");
        console2.log("[ARRANGE] Submit and finalize nonce=1 checkpoint");
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

        console2.log("[ACT] Re-submit another checkpoint with same nonce=1");
        bytes memory opSig2 = _signCheckpoint(cp, operatorPk);
        bytes[] memory userSigs2 = _toBytesArray(_signCheckpoint(cp, userPk));
        console2.log("[ASSERT] Duplicate nonce is rejected");
        vm.expectRevert();
        channel.submitCheckpoint(cp, deltas, opSig2, _toArray(user), userSigs2);
    }

    function testRejectsInvalidOperatorSig() public {
        console2.log("[TEST] testRejectsInvalidOperatorSig");
        console2.log("[ARRANGE] Build valid checkpoint but sign operator slot with user key");
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
        console2.log("[ASSERT] Invalid operator signature reverts");
        vm.expectRevert();
        channel.submitCheckpoint(cp, deltas, wrongOpSig, _toArray(user), userSigs);
    }

    function testRejectsInvalidUserSig() public {
        console2.log("[TEST] testRejectsInvalidUserSig");
        console2.log("[ARRANGE] Build valid checkpoint but sign user slot with operator key");
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
        console2.log("[ASSERT] Invalid user signature reverts");
        vm.expectRevert();
        channel.submitCheckpoint(cp, deltas, opSig, _toArray(user), wrongUserSigs);
    }

    function testChallengeBeforeDeadlineSucceeds() public {
        console2.log("[TEST] testChallengeBeforeDeadlineSucceeds");
        console2.log("[ARRANGE] Submit pending checkpoint nonce=5");
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

        console2.log("[ACT] Challenge with newer nonce=6 before challenge window closes");
        channel.challengeCheckpoint(
            cp2,
            deltas2,
            _signCheckpoint(cp2, operatorPk),
            _toArray(user),
            _toBytesArray(_signCheckpoint(cp2, userPk))
        );

        console2.log("[ASSERT] No final nonce yet and pending record replaced with nonce=6");
        assertEq(channel.latestNonce(marketId, sessionId), 0);
        bytes32 key = keccak256(abi.encode(marketId, sessionId));
        (uint64 pendingNonce, , , , , , bool exists) = channel.pendingByKey(key);
        assertTrue(exists);
        assertEq(pendingNonce, 6);
    }

    function testFinalizeBeforeDeadlineFails() public {
        console2.log("[TEST] testFinalizeBeforeDeadlineFails");
        console2.log("[ARRANGE] Submit checkpoint and attempt immediate finalize");
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

        console2.log("[ASSERT] Finalization before challenge deadline reverts");
        vm.expectRevert();
        channel.finalizeCheckpoint(marketId, sessionId, deltas);
    }

    function testReplayAcrossSessionReverts() public {
        console2.log("[TEST] testReplayAcrossSessionReverts");
        console2.log("[ARRANGE] Finalize checkpoint in session-1 then replay same nonce in session-2");
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

        bytes32 otherSessionId = keccak256("session-2");
        ShadowTypes.Checkpoint memory cpReplay = _makeCheckpoint(1, dHash);
        cpReplay.sessionId = otherSessionId;
        bytes32 dHash2 = Hashing.hashDeltas(deltas);
        cpReplay.deltasHash = dHash2;

        console2.log("[ACT] Finalize replayed checkpoint under different session id");
        channel.submitCheckpoint(
            cpReplay,
            deltas,
            _signCheckpoint(cpReplay, operatorPk),
            _toArray(user),
            _toBytesArray(_signCheckpoint(cpReplay, userPk))
        );
        vm.warp(block.timestamp + 31 minutes);
        channel.finalizeCheckpoint(marketId, otherSessionId, deltas);

        console2.log("[ASSERT] Original session has no pending checkpoint and re-finalize reverts");
        vm.expectRevert(Errors.NoPending.selector);
        channel.finalizeCheckpoint(marketId, sessionId, deltas);
    }

    function testFinalizeAfterDeadlineSucceeds() public {
        console2.log("[TEST] testFinalizeAfterDeadlineSucceeds");
        console2.log("[ARRANGE] Submit checkpoint that grants user shares and debits cash");
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

        console2.log("[ACT] Warp past challenge window and finalize");
        vm.warp(block.timestamp + 31 minutes);
        channel.finalizeCheckpoint(marketId, sessionId, deltas);

        console2.log("[ASSERT] OutcomeToken balance and vault free balance reflect finalized deltas");
        uint256 tokenId = outcomeToken.id(marketId, 0);
        assertEq(outcomeToken.balanceOf(user, tokenId), 10);
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
