// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {ShadowTypes} from "../src/libs/ShadowTypes.sol";
import {Hashing} from "../src/libs/Hashing.sol";
import {OutcomeToken1155} from "../src/execution/OutcomeToken1155.sol";
import {CollateralVault} from "../src/execution/CollateralVault.sol";
import {ChannelSettlement} from "../src/execution/ChannelSettlement.sol";
import {MarketRegistry} from "../src/core/MarketRegistry.sol";
import {Errors} from "../src/utils/Errors.sol";

contract OutcomeTokenFlowTest is Test {
    ERC20Mock token;
    CollateralVault vault;
    OutcomeToken1155 outcomeToken;
    ChannelSettlement channel;
    MarketRegistry marketRegistry;

    uint256 operatorPk = 0xA11CE;
    address operator;
    uint256 userPk = 0xB0B;
    address user;

    uint256 marketId = 0;
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
        marketRegistry.setSettlementRouter(address(this));

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

    function testFinalizeMints1155ForPositiveSharesDelta() public {
        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](1);
        deltas[0] = ShadowTypes.Delta({user: user, outcomeIndex: 0, sharesDelta: 10, cashDelta: -1000});
        bytes32 dHash = Hashing.hashDeltas(deltas);
        ShadowTypes.Checkpoint memory cp = _makeCheckpoint(1, dHash);

        channel.submitCheckpoint(cp, deltas, _signCheckpoint(cp, operatorPk), _toArray(user), _toBytesArray(_signCheckpoint(cp, userPk)));
        vm.warp(block.timestamp + 31 minutes);
        channel.finalizeCheckpoint(marketId, sessionId, deltas);

        uint256 tokenId = outcomeToken.id(marketId, 0);
        assertEq(outcomeToken.balanceOf(user, tokenId), 10);
    }

    function testFinalizeBurns1155ForNegativeSharesDelta() public {
        ShadowTypes.Delta[] memory deltas1 = new ShadowTypes.Delta[](1);
        deltas1[0] = ShadowTypes.Delta({user: user, outcomeIndex: 0, sharesDelta: 10, cashDelta: -1000});
        bytes32 dHash1 = Hashing.hashDeltas(deltas1);
        ShadowTypes.Checkpoint memory cp1 = _makeCheckpoint(1, dHash1);
        channel.submitCheckpoint(cp1, deltas1, _signCheckpoint(cp1, operatorPk), _toArray(user), _toBytesArray(_signCheckpoint(cp1, userPk)));
        vm.warp(block.timestamp + 31 minutes);
        channel.finalizeCheckpoint(marketId, sessionId, deltas1);

        ShadowTypes.Delta[] memory deltas2 = new ShadowTypes.Delta[](1);
        deltas2[0] = ShadowTypes.Delta({user: user, outcomeIndex: 0, sharesDelta: -5, cashDelta: 500});
        bytes32 dHash2 = Hashing.hashDeltas(deltas2);
        ShadowTypes.Checkpoint memory cp2 = _makeCheckpoint(2, dHash2);
        channel.submitCheckpoint(cp2, deltas2, _signCheckpoint(cp2, operatorPk), _toArray(user), _toBytesArray(_signCheckpoint(cp2, userPk)));
        vm.warp(block.timestamp + 31 minutes);
        channel.finalizeCheckpoint(marketId, sessionId, deltas2);

        uint256 tokenId = outcomeToken.id(marketId, 0);
        assertEq(outcomeToken.balanceOf(user, tokenId), 5);
    }

    function testTransferLockedPreResolution() public {
        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](1);
        deltas[0] = ShadowTypes.Delta({user: user, outcomeIndex: 0, sharesDelta: 10, cashDelta: -1000});
        bytes32 dHash = Hashing.hashDeltas(deltas);
        ShadowTypes.Checkpoint memory cp = _makeCheckpoint(1, dHash);
        channel.submitCheckpoint(cp, deltas, _signCheckpoint(cp, operatorPk), _toArray(user), _toBytesArray(_signCheckpoint(cp, userPk)));
        vm.warp(block.timestamp + 31 minutes);
        channel.finalizeCheckpoint(marketId, sessionId, deltas);

        uint256 tokenId = outcomeToken.id(marketId, 0);
        vm.prank(user);
        vm.expectRevert(Errors.TransferLocked.selector);
        outcomeToken.safeTransferFrom(user, address(0x123), tokenId, 1, "");
    }

    function testTransferAllowedPostResolution() public {
        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](1);
        deltas[0] = ShadowTypes.Delta({user: user, outcomeIndex: 0, sharesDelta: 10, cashDelta: -1000});
        bytes32 dHash = Hashing.hashDeltas(deltas);
        ShadowTypes.Checkpoint memory cp = _makeCheckpoint(1, dHash);
        channel.submitCheckpoint(cp, deltas, _signCheckpoint(cp, operatorPk), _toArray(user), _toBytesArray(_signCheckpoint(cp, userPk)));
        vm.warp(block.timestamp + 31 minutes);
        channel.finalizeCheckpoint(marketId, sessionId, deltas);

        vm.prank(marketRegistry.settlementRouter());
        marketRegistry.resolve(marketId, 0, 9000);

        uint256 tokenId = outcomeToken.id(marketId, 0);
        address receiver = address(0x456);
        vm.prank(user);
        outcomeToken.safeTransferFrom(user, receiver, tokenId, 3, "");
        assertEq(outcomeToken.balanceOf(user, tokenId), 7);
        assertEq(outcomeToken.balanceOf(receiver, tokenId), 3);
    }

    function testRedeemBurnsAndPays() public {
        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](1);
        deltas[0] = ShadowTypes.Delta({user: user, outcomeIndex: 0, sharesDelta: 10, cashDelta: -1000});
        bytes32 dHash = Hashing.hashDeltas(deltas);
        ShadowTypes.Checkpoint memory cp = _makeCheckpoint(1, dHash);
        channel.submitCheckpoint(cp, deltas, _signCheckpoint(cp, operatorPk), _toArray(user), _toBytesArray(_signCheckpoint(cp, userPk)));
        vm.warp(block.timestamp + 31 minutes);
        channel.finalizeCheckpoint(marketId, sessionId, deltas);

        vm.prank(marketRegistry.settlementRouter());
        marketRegistry.resolve(marketId, 0, 9000);

        uint256 balBefore = token.balanceOf(user);
        vm.prank(user);
        uint256 payout = marketRegistry.redeem(marketId);
        assertEq(payout, 10);
        assertEq(token.balanceOf(user), balBefore + 10);
        uint256 tokenId = outcomeToken.id(marketId, 0);
        assertEq(outcomeToken.balanceOf(user, tokenId), 0);
    }

    function testBurnFailsInsufficientBalance() public {
        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](1);
        deltas[0] = ShadowTypes.Delta({user: user, outcomeIndex: 0, sharesDelta: -10, cashDelta: 1000});
        bytes32 dHash = Hashing.hashDeltas(deltas);
        ShadowTypes.Checkpoint memory cp = _makeCheckpoint(1, dHash);
        channel.submitCheckpoint(cp, deltas, _signCheckpoint(cp, operatorPk), _toArray(user), _toBytesArray(_signCheckpoint(cp, userPk)));
        vm.warp(block.timestamp + 31 minutes);
        vm.expectRevert();
        channel.finalizeCheckpoint(marketId, sessionId, deltas);
    }
}
