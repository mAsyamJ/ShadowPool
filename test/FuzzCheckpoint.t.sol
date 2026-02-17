// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {ShadowTypes} from "../src/libs/ShadowTypes.sol";
import {Hashing} from "../src/libs/Hashing.sol";
import {CollateralVault} from "../src/execution/CollateralVault.sol";
import {ExecutionLedger} from "../src/execution/ExecutionLedger.sol";
import {ChannelSettlement} from "../src/execution/ChannelSettlement.sol";

/// @title FuzzCheckpointTest
/// @notice Fuzz checkpoint flow with bounded random deltas.
contract FuzzCheckpointTest is Test {
    ERC20Mock token;
    CollateralVault vault;
    ExecutionLedger ledger;
    ChannelSettlement channel;

    uint256 operatorPk = 0xA11CE;
    address operator;
    uint256 userPk = 0xB0B;
    address user;

    function setUp() public {
        operator = vm.addr(operatorPk);
        user = vm.addr(userPk);

        token = new ERC20Mock();
        token.mint(address(this), 10000 ether);
        token.mint(user, 10000 ether);

        vault = new CollateralVault(address(token), address(0));
        ledger = new ExecutionLedger(address(0));
        channel = new ChannelSettlement(address(vault), address(ledger), operator);

        vault.setChannelSettlement(address(channel));
        ledger.setChannelSettlement(address(channel));

        token.approve(address(vault), 10000 ether);
        vault.deposit(1000 ether);
        vm.prank(user);
        token.approve(address(vault), 10000 ether);
        vm.prank(user);
        vault.deposit(1000 ether);
    }

    function testFuzzCheckpointWithBoundedDeltas(uint256 sharesDeltaRaw, uint256 cashDeltaRaw) public {
        console2.log("[TEST] testFuzzCheckpointWithBoundedDeltas");
        console2.log("[ARRANGE] Bound fuzzed shares/cash deltas to safe signed ranges");
        // casting to 'int128' is safe because sharesDeltaRaw is bounded to [0,100]
        // forge-lint: disable-next-line(unsafe-typecast)
        int128 sharesDelta = int128(uint128(bound(sharesDeltaRaw, 0, 100)));
        uint256 cashBound = bound(cashDeltaRaw, 0, 2000);
        // casting to int256/int128 is safe because cashBound in [0,2000] makes (cashBound-1000) fit int128
        // forge-lint: disable-next-line(unsafe-typecast)
        int128 cashDelta = int128(int256(cashBound) - 1000);

        uint256 marketId = 0;
        bytes32 sessionId = keccak256("fuzz-session");
        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](1);
        deltas[0] = ShadowTypes.Delta({
            user: user,
            outcomeIndex: 0,
            sharesDelta: sharesDelta,
            cashDelta: cashDelta
        });

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

        console2.log("[ACT] Submit and finalize fuzzed checkpoint");
        channel.submitCheckpoint(
            cp,
            deltas,
            _signCheckpoint(cp, operatorPk),
            _toArray(user),
            _toBytesArray(_signCheckpoint(cp, userPk))
        );
        vm.warp(block.timestamp + 31 minutes);
        channel.finalizeCheckpoint(marketId, sessionId, deltas);

        console2.log("[ASSERT] Ledger position equals fuzzed shares delta");
        assertEq(
            ledger.positionOf(user, marketId, 0),
            int256(sharesDelta),
            "position should match shares delta"
        );
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
}
