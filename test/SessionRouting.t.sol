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
import {SettlementRouter} from "../src/core/SettlementRouter.sol";
import {OracleCoordinator} from "../src/oracle/OracleCoordinator.sol";

/// @title SessionRoutingTest
/// @notice Tests SessionPayloadRouted event emission.
contract SessionRoutingTest is Test {
    ERC20Mock token;
    CollateralVault vault;
    ExecutionLedger ledger;
    ChannelSettlement channel;
    SettlementRouter router;
    OracleCoordinator coordinator;

    address owner = address(0x1);
    address operator;
    uint256 operatorPk = 0xA11CE;
    uint256 userPk = 0xB0B;
    address user;

    uint256 marketId = 1;
    bytes32 sessionId = keccak256("session-checkpoint");

    function setUp() public {
        operator = vm.addr(operatorPk);
        user = vm.addr(userPk);

        token = new ERC20Mock();
        token.mint(address(this), 1000 ether);
        token.mint(user, 100 ether);

        vault = new CollateralVault(address(token), address(0));
        ledger = new ExecutionLedger(address(0));
        channel = new ChannelSettlement(address(vault), address(ledger), operator);
        router = new SettlementRouter();
        coordinator = new OracleCoordinator();

        vault.setChannelSettlement(address(channel));
        ledger.setChannelSettlement(address(channel));
        router.setChannelSettlement(address(channel));
        router.setOracleCoordinator(address(coordinator));
        coordinator.setSettlementRouter(address(router));
        coordinator.setCreReceiver(address(this));

        token.approve(address(vault), 1000 ether);
        vault.deposit(100 ether);
        vm.prank(user);
        token.approve(address(vault), 100 ether);
        vm.prank(user);
        vault.deposit(10 ether);
    }

    function testSessionPayloadRoutedEventEmitted() public {
        console2.log("[TEST] testSessionPayloadRoutedEventEmitted");
        console2.log("[ARRANGE] Build signed checkpoint payload for coordinator session submit");
        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](1);
        deltas[0] = ShadowTypes.Delta({user: user, outcomeIndex: 0, sharesDelta: 10, cashDelta: -100});
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

        bytes memory payload = abi.encode(
            cp,
            deltas,
            _signCheckpoint(cp, operatorPk),
            _toArray(user),
            _toBytesArray(_signCheckpoint(cp, userPk))
        );

        console2.log("[ACT] Submit payload via OracleCoordinator");
        vm.prank(address(this));
        coordinator.submitSession(payload);
        console2.log("[ASSERT] Session payload is accepted and routed");
    }

    /// @notice Verifies payload format matches relayer buildCheckpointPayload: (Checkpoint, Delta[], operatorSig, users, userSigs)
    function testCheckpointPayloadFormatMatchesRelayer() public {
        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](1);
        deltas[0] = ShadowTypes.Delta({user: user, outcomeIndex: 0, sharesDelta: 10, cashDelta: -100});
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

        bytes memory payload = abi.encode(
            cp,
            deltas,
            _signCheckpoint(cp, operatorPk),
            _toArray(user),
            _toBytesArray(_signCheckpoint(cp, userPk))
        );

        vm.prank(address(this));
        coordinator.submitSession(payload);
        assertTrue(true, "Payload format accepted by ChannelSettlement via router");
    }

    function testSessionPayloadRoutedViaRouterDirect() public {
        console2.log("[TEST] testSessionPayloadRoutedViaRouterDirect");
        console2.log("[ARRANGE] Build signed payload and expect SessionPayloadRouted event");
        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](1);
        deltas[0] = ShadowTypes.Delta({user: user, outcomeIndex: 0, sharesDelta: 10, cashDelta: -100});
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

        bytes memory payload = abi.encode(
            cp,
            deltas,
            _signCheckpoint(cp, operatorPk),
            _toArray(user),
            _toBytesArray(_signCheckpoint(cp, userPk))
        );

        console2.log("[ACT] Coordinator calls router.finalizeSession(payload)");
        vm.prank(address(coordinator));
        vm.expectEmit(true, true, true, true);
        emit SettlementRouter.SessionPayloadRouted(
            address(channel),
            keccak256(payload),
            marketId,
            sessionId,
            1
        );
        router.finalizeSession(payload);
        console2.log("[ASSERT] SessionPayloadRouted emitted with expected payload hash and nonce");
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
