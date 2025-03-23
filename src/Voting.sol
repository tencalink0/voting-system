// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    mapping(address => bool) public voters;
    mapping(string => uint256) public votes;

    string[] public candidates;

    constructor(string[] memory _candidates) {
        candidates = _candidates;
    }
}