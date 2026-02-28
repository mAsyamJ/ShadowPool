// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {OutcomeToken1155} from "../src/execution/OutcomeToken1155.sol";
import {MarketRiskManager} from "../src/execution/MarketRiskManager.sol";
import {CollateralVault} from "../src/execution/CollateralVault.sol";
import {ChannelSettlement} from "../src/execution/ChannelSettlement.sol";
import {MarketRegistry} from "../src/core/MarketRegistry.sol";
import {LiquidityVault4626} from "../src/execution/LiquidityVault4626.sol";
import {Errors} from "../src/utils/Errors.sol";

contract RiskManagerFlowTest is Test {
    ERC20Mock token;
    CollateralVault vault;
    OutcomeToken1155 outcomeToken;
    MarketRiskManager riskManager;
    ChannelSettlement channel;
    MarketRegistry marketRegistry;
    LiquidityVault4626 lpVault;

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
        token.mint(address(this), 10000 ether);
        token.mint(user, 100 ether);

        vault = new CollateralVault(address(token), address(0));
        outcomeToken = new OutcomeToken1155("https://api.retropick.xyz/outcome/{id}.json");
        riskManager = new MarketRiskManager();
        channel = new ChannelSettlement(address(vault), address(0), operator);
        marketRegistry = new MarketRegistry(address(vault), address(0));
        lpVault = new LiquidityVault4626(address(token), address(channel));

        vm.startPrank(channel.owner());
        channel.setOutcomeToken(address(outcomeToken));
        channel.setRiskManager(address(riskManager));
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
        vm.prank(riskManager.owner());
        riskManager.setChannelSettlement(address(channel));

        vm.prank(marketRegistry.owner());
        marketRegistry.createMarketForWithExpiryAndAsset("Test", address(this), uint48(block.timestamp + 86400), address(token));
        vm.prank(marketRegistry.owner());
        marketRegistry.setLiquidityVault(marketId, address(lpVault));

        token.transfer(address(lpVault), 100 ether);
        vault.setChannelSettlement(address(channel));
        token.approve(address(vault), 1000 ether);
        vault.deposit(100 ether);
        vm.prank(user);
        token.approve(address(vault), 100 ether);
        vm.prank(user);
        vault.deposit(10 ether);
    }

    function testReserveWithinCap() public {
        vm.prank(riskManager.owner());
        riskManager.setMaxLpPayout(marketId, 100);
        assertEq(riskManager.reservedLpPayout(marketId), 0);
        vm.prank(address(channel));
        riskManager.reserveLpPayout(marketId, 50);
        assertEq(riskManager.reservedLpPayout(marketId), 50);
        vm.prank(address(channel));
        riskManager.reserveLpPayout(marketId, 50);
        assertEq(riskManager.reservedLpPayout(marketId), 100);
    }

    function testReserveExceedsCap() public {
        vm.prank(riskManager.owner());
        riskManager.setMaxLpPayout(marketId, 100);
        vm.prank(address(channel));
        riskManager.reserveLpPayout(marketId, 50);
        vm.prank(address(channel));
        vm.expectRevert(Errors.RiskCapExceeded.selector);
        riskManager.reserveLpPayout(marketId, 51);
    }

    function testReserveOnlyWhenLpOwes() public {
        vm.prank(riskManager.owner());
        riskManager.setMaxLpPayout(marketId, 1000);
        vm.prank(address(channel));
        riskManager.reserveLpPayout(marketId, 50);
        assertEq(riskManager.reservedLpPayout(marketId), 50);
    }

    function testSetMaxLpPayoutAtPublish() public {
        assertEq(riskManager.maxLpPayout(marketId), 0);
        vm.prank(riskManager.owner());
        riskManager.setMaxLpPayout(marketId, 150);
        assertEq(riskManager.maxLpPayout(marketId), 150);
    }
}
