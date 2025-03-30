// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Voting.sol";

contract Voting is Test {
    Voting public voting;
    address public addr1;
    address public addr2;
    address public addr3;
    Voting.Candidate[] public candidates;


    function init() {
        addr1 = address(0x001);
        addr2 = address(0x002);
        addr3 = address(0x003);

        candidates.push(Voting.Candidates("tenca", addr1));
        candidates.push(Voting.Candidate("link", addr2));
        candidates.push(Voting.Candidate("zero", addr3));

        // voting deployment
        voting = new Voting(candidates, 60);
    }

    function testInitValues() {
        assertEq(voting.getCandidateAddr("tenca"), addr1);
        assertEq(voting.getCandidateAddr("link"), addr2);
        assertEq(voting.getCandidateAddr("zero"), addr3);
        
        uint256 deadline = voting.votingDeadline();
        assertGt(deadline, block.timestamp); // assert greater than
        assertEq(deadline, block.timestamp);
    }

    function testVoting() {
        vm.prank(addr2); // simulates being addr2
        voting.vote(addr1);

        uint256 votesAddr1 = voting.votes(addr1);
        assertEq(votesAddr1, 1);
    }
}
