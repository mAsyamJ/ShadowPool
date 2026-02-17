// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {PoolMarketLegacy} from "../src/core/PoolMarketLegacy.sol";
import {SettlementRouter} from "../src/core/SettlementRouter.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {OracleCoordinator} from "../src/oracle/OracleCoordinator.sol";
import {CREReceiver} from "../src/oracle/CREReceiver.sol";

contract OracleFlowTest is Test {
    SettlementRouter private router;
    OracleCoordinator private coordinator;
    CREReceiver private receiver;
    PoolMarketLegacy private market;
    ERC20Mock private token;

    address private forwarder = address(0x1234);

    function setUp() public {
        router = new SettlementRouter();
        coordinator = new OracleCoordinator();
        receiver = new CREReceiver(forwarder, address(coordinator));

        router.setOracleCoordinator(address(coordinator));
        coordinator.setCreReceiver(address(receiver));
        coordinator.setSettlementRouter(address(router));

        token = new ERC20Mock();
        token.mint(address(this), 1000 ether);
        market = new PoolMarketLegacy(address(router), address(token));
        market.createMarket("Will BTC be above 50k?");
    }

    function testSettlementViaCREReceiver() public {
        console2.log("[TEST] testSettlementViaCREReceiver");
        console2.log("[ARRANGE] Build CRE settlement report for marketId=0 outcome=0 confidence=9000");
        bytes memory report = abi.encode(address(market), uint256(0), uint8(0), uint16(9000));
        console2.log("[ACT] Forwarder submits report to CREReceiver");
        vm.prank(forwarder);
        receiver.onReport("", report);

        console2.log("[ACT] Read settled market state");
        PoolMarketLegacy.Market memory m = market.getMarket(0);

        console2.log("[ASSERT] Market settled with expected confidence and outcome");
        assertTrue(m.settled);
        assertEq(m.confidence, 9000);
        assertEq(uint8(m.outcome), 0);
    }
}
