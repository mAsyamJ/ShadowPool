// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {ShadowTypes} from "../src/libs/ShadowTypes.sol";
import {Hashing} from "../src/libs/Hashing.sol";
import {MarketRegistry} from "../src/core/MarketRegistry.sol";
import {CollateralVault} from "../src/execution/CollateralVault.sol";
import {ExecutionLedger} from "../src/execution/ExecutionLedger.sol";
import {ChannelSettlement} from "../src/execution/ChannelSettlement.sol";
import {FeeManager} from "../src/fees/FeeManager.sol";
import {FeePool} from "../src/fees/FeePool.sol";
import {TreasuryPool} from "../src/fees/TreasuryPool.sol";
import {LiquidityVault4626} from "../src/execution/LiquidityVault4626.sol";
import {Errors} from "../src/utils/Errors.sol";

/// @title InvariantSolvencyTest
/// @notice Solvency invariant and LP fee routing tests.
contract InvariantSolvencyTest is Test {
    ERC20Mock token;
    CollateralVault vault;
    ExecutionLedger ledger;
    ChannelSettlement channel;
    MarketRegistry registry;
    FeeManager feeManager;
    FeePool feePool;
    TreasuryPool treasuryPool;
    LiquidityVault4626 lpVault;

    address owner = address(0x1);
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
        token.mint(address(this), 10000 ether);
        token.mint(user, 100 ether);

        vault = new CollateralVault(address(token), address(0));
        ledger = new ExecutionLedger(address(0));
        channel = new ChannelSettlement(address(vault), address(ledger), operator);
        registry = new MarketRegistry(address(vault), address(ledger));

        vault.setChannelSettlement(address(channel));
        ledger.setChannelSettlement(address(channel));
        channel.setMarketRegistry(address(registry));
        registry.setMarketFactory(owner);

        feeManager = new FeeManager(100);
        feeManager.setLpFeeShareBps(2000);
        feeManager.setCreatorFeeShareBps(1000);
        feePool = new FeePool();
        treasuryPool = new TreasuryPool();
        feePool.setFeeCollector(address(channel));
        feePool.setTreasuryPool(address(treasuryPool));
        channel.setFeeManager(address(feeManager));
        channel.setFeePool(address(feePool));

        registry.createMarketForWithExpiryAndAsset("Test", owner, uint48(block.timestamp + 86400), address(token));
        lpVault = new LiquidityVault4626(address(token), address(channel));
        registry.setLiquidityVault(marketId, address(lpVault));
        vm.stopPrank();

        token.approve(address(vault), 1000 ether);
        vault.deposit(100 ether);
        vm.prank(user);
        token.approve(address(vault), 100 ether);
        vm.prank(user);
        vault.deposit(10 ether);
    }

    function testFinalizeWithLpMarketRequiresVault() public {
        console2.log("[TEST] testFinalizeWithLpMarketRequiresVault");
        console2.log("[ARRANGE] Create LP market then clear its liquidity vault reference");
        vm.startPrank(owner);
        registry.createMarketForWithExpiryAndAsset("LP Market", owner, uint48(block.timestamp + 86400), address(token));
        uint256 mkId = 1;
        registry.setLiquidityVault(mkId, address(lpVault));
        registry.setLiquidityVault(mkId, address(0));
        vm.stopPrank();

        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](1);
        deltas[0] = ShadowTypes.Delta({user: user, outcomeIndex: 0, sharesDelta: 10, cashDelta: -100});
        bytes32 dHash = Hashing.hashDeltas(deltas);
        ShadowTypes.Checkpoint memory cp = ShadowTypes.Checkpoint({
            marketId: mkId,
            sessionId: sessionId,
            nonce: 1,
            validAfter: 0,
            validBefore: 0,
            lastTradeAt: 0,
            stateHash: keccak256("state"),
            deltasHash: dHash,
            riskHash: bytes32(0)
        });

        console2.log("[ACT] Submit checkpoint and finalize after deadline");
        channel.submitCheckpoint(
            cp,
            deltas,
            _signCheckpoint(cp, operatorPk),
            _toArray(user),
            _toBytesArray(_signCheckpoint(cp, userPk))
        );
        vm.warp(block.timestamp + 31 minutes);

        console2.log("[ASSERT] Finalize reverts because LP market must have liquidity vault");
        vm.expectRevert(Errors.LiquidityVaultRequired.selector);
        channel.finalizeCheckpoint(mkId, sessionId, deltas);
    }

    function testEscrowAvailableBalanceInvariant() public {
        console2.log("[TEST] testEscrowAvailableBalanceInvariant");
        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](1);
        deltas[0] = ShadowTypes.Delta({user: user, outcomeIndex: 0, sharesDelta: 10, cashDelta: -1000});
        ShadowTypes.Checkpoint memory cp = _cp(deltas);

        channel.submitCheckpoint(cp, deltas, _signCheckpoint(cp, operatorPk), _toArray(user), _toBytesArray(_signCheckpoint(cp, userPk)));

        assertLe(vault.availableBalance(user), vault.freeBalance(user));
        assertEq(vault.reservedBalance(user), 1000);
    }

    function testLpFeeWithNoLpSupplyRoutesToTreasury() public {
        console2.log("[TEST] testLpFeeWithNoLpSupplyRoutesToTreasury");
        console2.log("[ARRANGE] LP fee share enabled while LP vault has zero supply");
        uint256 loserPk = 0xCAFE;
        address loser = vm.addr(loserPk);
        token.mint(loser, 100 ether);
        vm.prank(loser);
        token.approve(address(vault), 100 ether);
        vm.prank(loser);
        vault.deposit(10 ether);

        vm.prank(owner);
        feeManager.setLpFeeShareBps(3000);

        uint256 treasuryBefore = token.balanceOf(address(treasuryPool));

        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](2);
        deltas[0] = ShadowTypes.Delta({user: loser, outcomeIndex: 0, sharesDelta: 0, cashDelta: -1000});
        deltas[1] = ShadowTypes.Delta({user: user, outcomeIndex: 0, sharesDelta: 0, cashDelta: 1000});
        address[] memory users = new address[](2);
        users[0] = loser;
        users[1] = user;
        bytes[] memory sigs = new bytes[](2);
        sigs[0] = _signCheckpoint(_cp(deltas), loserPk);
        sigs[1] = _signCheckpoint(_cp(deltas), userPk);

        ShadowTypes.Checkpoint memory cp = _cp(deltas);
        console2.log("[ACT] Finalize profitable checkpoint with protocol fees");
        channel.submitCheckpoint(cp, deltas, _signCheckpoint(cp, operatorPk), users, sigs);
        vm.warp(block.timestamp + 31 minutes);
        channel.finalizeCheckpoint(marketId, sessionId, deltas);

        console2.log("[ASSERT] LP fee portion falls back to treasury pool");
        assertGt(token.balanceOf(address(treasuryPool)), treasuryBefore, "LP fee routes to treasury when vault supply is 0");
    }

    function _cp(ShadowTypes.Delta[] memory deltas) internal view returns (ShadowTypes.Checkpoint memory) {
        return ShadowTypes.Checkpoint({
            marketId: marketId,
            sessionId: sessionId,
            nonce: 1,
            validAfter: 0,
            validBefore: 0,
            lastTradeAt: 0,
            stateHash: keccak256("state"),
            deltasHash: Hashing.hashDeltas(deltas),
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

    function _toBytesArray2(bytes memory a, bytes memory b) internal pure returns (bytes[] memory) {
        bytes[] memory arr = new bytes[](2);
        arr[0] = a;
        arr[1] = b;
        return arr;
    }
}
