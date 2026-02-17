// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {FeeManager} from "../src/fees/FeeManager.sol";

/// @title FuzzFeeSplitTest
/// @notice Fuzz FeeManager.computeSplit for split sum correctness.
contract FuzzFeeSplitTest is Test {
    FeeManager feeManager;
    address owner = address(0x1);

    function setUp() public {
        vm.prank(owner);
        feeManager = new FeeManager(100);
        vm.prank(owner);
        feeManager.setLpFeeShareBps(2500);
        vm.prank(owner);
        feeManager.setCreatorFeeShareBps(1500);
    }

    function testFuzzComputeSplitSumCorrectness(int128 pnlDelta) public view {
        console2.log("[TEST] testFuzzComputeSplitSumCorrectness");
        console2.log("[ARRANGE] Keep fuzzed pnlDelta positive and within configured bound");
        vm.assume(pnlDelta > 0);
        vm.assume(pnlDelta <= 1e18);

        console2.log("[ACT] Compute protocol/lp/creator split");
        (uint256 protocolFee, uint256 lpFee, uint256 creatorFee, int128 netDelta) =
            feeManager.computeSplit(pnlDelta);

        uint256 totalFee = protocolFee + lpFee + creatorFee;
        // casting to 'uint256' is safe because pnlDelta is assumed > 0
        // forge-lint: disable-next-line(unsafe-typecast)
        uint256 profit = uint256(int256(pnlDelta));
        // casting to 'uint256' is safe because netDelta is non-negative when pnlDelta is positive
        // forge-lint: disable-next-line(unsafe-typecast)
        uint256 netU = uint256(int256(netDelta));
        uint256 diff = profit > totalFee + netU ? profit - totalFee - netU : totalFee + netU - profit;
        console2.log("[ASSERT] Total fees + net is equal to profit within tiny rounding dust");
        assertLe(diff, 2, "rounding dust at most 2 wei from multi-step division");
    }
}
