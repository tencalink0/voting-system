// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Voting.sol";

contract Deploy is Script {
    Voting.Candidate[] public candidates;
    
    function run() external {
        candidates[0] = Voting.Candidate({name: "tencalink0", addr: 0x1000000000000000000000000000000000000001});
        candidates[1] = Voting.Candidate({name: "bev29rr", addr: 0x2000000000000000000000000000000000000002});

        vm.startBroadcast();
        Voting voting = new Voting(candidates, 5 days);
        vm.stopBroadcast();
    }
}