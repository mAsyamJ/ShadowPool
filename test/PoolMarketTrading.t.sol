// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {PoolMarketLegacy} from "../src/core/PoolMarketLegacy.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract PoolMarketTradingTest is Test {
    PoolMarketLegacy private market;
    ERC20Mock private token;
    address private forwarder = address(0x1234);
    address private user = address(0xBEEF);

    function setUp() public {
        token = new ERC20Mock();
        token.mint(user, 100 ether);
        market = new PoolMarketLegacy(forwarder, address(token));
        market.createMarket("Will X happen?");
    }

    function testAddToPosition() public {
        vm.startPrank(user);
        token.approve(address(market), 10 ether);
        market.predict(0, PoolMarketLegacy.Prediction.Yes, 5 ether);
        market.predict(0, PoolMarketLegacy.Prediction.Yes, 5 ether);
        vm.stopPrank();

        PoolMarketLegacy.UserPrediction memory pred = market.getPrediction(0, user);
        assertEq(pred.amount, 10 ether);
        assertEq(uint8(pred.prediction), uint8(PoolMarketLegacy.Prediction.Yes));
    }

    function testReducePosition() public {
        vm.prank(user);
        token.approve(address(market), 10 ether);
        vm.prank(user);
        market.predict(0, PoolMarketLegacy.Prediction.Yes, 10 ether);

        uint256 balBefore = token.balanceOf(user);
        vm.prank(user);
        market.reducePosition(0, 4 ether);
        assertEq(token.balanceOf(user), balBefore + 4 ether);

        PoolMarketLegacy.UserPrediction memory pred = market.getPrediction(0, user);
        assertEq(pred.amount, 6 ether);
    }

    function testSwitchOutcome() public {
        vm.startPrank(user);
        token.approve(address(market), 20 ether);
        market.predict(0, PoolMarketLegacy.Prediction.Yes, 10 ether);
        uint256 bal = token.balanceOf(user);

        market.reduceAll(0);
        assertEq(token.balanceOf(user), bal + 10 ether);

        token.approve(address(market), 10 ether);
        market.predict(0, PoolMarketLegacy.Prediction.No, 10 ether);

        PoolMarketLegacy.UserPrediction memory pred = market.getPrediction(0, user);
        assertEq(pred.amount, 10 ether);
        assertEq(uint8(pred.prediction), uint8(PoolMarketLegacy.Prediction.No));
        vm.stopPrank();
    }

    function testRevertWhenAddingToDifferentOutcome() public {
        vm.prank(user);
        token.approve(address(market), 20 ether);
        vm.prank(user);
        market.predict(0, PoolMarketLegacy.Prediction.Yes, 5 ether);

        vm.prank(user);
        vm.expectRevert(PoolMarketLegacy.WrongOutcomeToAdd.selector);
        market.predict(0, PoolMarketLegacy.Prediction.No, 5 ether);
    }

    function testRevertWhenReducingMoreThanPosition() public {
        vm.prank(user);
        token.approve(address(market), 10 ether);
        vm.prank(user);
        market.predict(0, PoolMarketLegacy.Prediction.Yes, 5 ether);

        vm.prank(user);
        vm.expectRevert(PoolMarketLegacy.CannotReduceMoreThanPosition.selector);
        market.reducePosition(0, 10 ether);
    }
}
