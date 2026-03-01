// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {ShadowTypes} from "../src/libs/ShadowTypes.sol";
import {Hashing} from "../src/libs/Hashing.sol";

contract OutputDeltasHash is Script {
    function run() external view {
        address user = vm.addr(0xB0B); // matches CheckpointFlow.t.sol userPk
        ShadowTypes.Delta[] memory deltas = new ShadowTypes.Delta[](1);
        deltas[0] = ShadowTypes.Delta({
            user: user,
            outcomeIndex: 0,
            sharesDelta: 10,
            cashDelta: -100
        });
        bytes32 dHash = Hashing.hashDeltas(deltas);
        console2.logBytes32(dHash);
    }
}
