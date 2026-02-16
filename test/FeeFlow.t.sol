// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {ShadowTypes} from "../src/libs/ShadowTypes.sol";
import {Hashing} from "../src/libs/Hashing.sol";
import {CollateralVault} from "../src/execution/CollateralVault.sol";
import {ExecutionLedger} from "../src/execution/ExecutionLedger.sol";
import {ChannelSettlement} from "../src/execution/ChannelSettlement.sol";
import {FeeManager} from "../src/fees/FeeManager.sol";
import {FeePool} from "../src/fees/FeePool.sol";
import {TreasuryPool} from "../src/fees/TreasuryPool.sol";

/// @title FeeFlowTest
/// @notice P1 fee stack tests.
contract FeeFlowTest is Test {
    ERC20Mock token;
    CollateralVault vault;
    ExecutionLedger ledger;
    ChannelSettlement channel;
    FeeManager feeManager;
    FeePool feePool;
    TreasuryPool treasuryPool;

    address owner = address(0x1);
    address operator;
    uint256 operatorPk = 0xA11CE;
    uint256 userPk = 0xB0B;
    uint256 spenderPk = 0xC0FFEE;
    address user;
    address spender;

    uint256 marketId = 0;
    bytes32 sessionId = keccak256("session-1");

    function setUp() public {
        vm.startPrank(owner);
        operator = vm.addr(operatorPk);
        user = vm.addr(userPk);
        spender = vm.addr(spenderPk);

        token = new ERC20Mock();
        token.mint(address(this), 1000 ether);
        token.mint(user, 100 ether);
        token.mint(spender, 100 ether);

        vault = new CollateralVault(address(token), address(0));
        ledger = new ExecutionLedger(address(0));
        channel = new ChannelSettlement(address(vault), address(ledger), operator);

        vault.setChannelSettlement(address(channel));
        ledger.setChannelSettlement(address(channel));

        feeManager = new FeeManager(100); // 1% fee
        feePool = new FeePool();
        treasuryPool = new TreasuryPool();

        feePool.setFeeCollector(address(channel));
        feePool.setTreasuryPool(address(treasuryPool));
        channel.setFeeManager(address(feeManager));
        channel.setFeePool(address(feePool));

        vm.stopPrank();

        token.approve(address(vault), 1000 ether);
        vault.deposit(100 ether);
        vm.prank(user);
        token.approve(address(vault), 100 ether);
        vm.prank(user);
        vault.deposit(10 ether);
    }

    function testFeeAppliedOnPositivePnl() public {
        vm.prank(spender);
        token.approve(address(vault), 100 ether);
        vm.prank(spender);
        vault.deposit(10 ether);

        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](2);
        deltas[0] = ShadowTypes.Delta({user: spender, outcomeIndex: 0, sharesDelta: 0, cashDelta: -1000});
        deltas[1] = ShadowTypes.Delta({user: user, outcomeIndex: 0, sharesDelta: 0, cashDelta: 1000});

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

        address[] memory users = new address[](2);
        users[0] = spender;
        users[1] = user;
        bytes[] memory userSigs = new bytes[](2);
        userSigs[0] = _signCheckpoint(cp, spenderPk);
        userSigs[1] = _signCheckpoint(cp, userPk);

        channel.submitCheckpoint(cp, deltas, _signCheckpoint(cp, operatorPk), users, userSigs);
        vm.warp(block.timestamp + 31 minutes);
        channel.finalizeCheckpoint(marketId, sessionId, deltas);

        uint256 expectedFee = 1000 * 100 / 10_000;
        assertEq(feePool.balanceOf(address(token)), expectedFee, "FeePool should have 1% of 1000");
        assertEq(vault.freeBalance(user), 10 ether + 1000 - expectedFee, "User gets net after fee");
        assertEq(vault.freeBalance(spender), 10 ether - 1000, "Spender debited");
    }

    function testFeeCapEnforcement() public {
        vm.prank(owner);
        vm.expectRevert(FeeManager.FeeExceedsCap.selector);
        feeManager.setProtocolFeeBps(201);
    }

    function _signCheckpoint(ShadowTypes.Checkpoint memory cp, uint256 pk) internal view returns (bytes memory) {
        bytes32 digest = channel.digestCheckpoint(cp);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest);
        return abi.encodePacked(r, s, v);
    }
}
