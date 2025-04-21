// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    struct Candidate {
        string name;
        address addr;
    }

    mapping(address => bool) public voters;
    mapping(address => uint256) public votes;
    mapping(string => address) public candidateAddr;
    mapping(address => string) public candidateName;

    address[] public candidates;
    uint256 public immutable votingDeadline;

    event VotingEnded(address[] winners);

    constructor(Candidate[] memory _candidates, uint256 _votePeriod) {
        for (uint256 i = 0; i < _candidates.length; i++) {
            candidates.push(_candidates[i].addr);
            candidateAddr[_candidates[i].name] = _candidates[i].addr;
            candidateName[_candidates[i].addr] = _candidates[i].name;
        }
        votingDeadline = block.timestamp + _votePeriod;
    }

    function vote(address _candidate) external {
        require(block.timestamp < votingDeadline, 'Voting has ended');
        require(bytes(candidateName[_candidate]).length > 0, 'Candidate does not exist');
        require(voters[msg.sender] != true, 'Already voted');

        votes[_candidate] += 1;
        voters[msg.sender] = true;
    }

    function getCandidateAddr(string calldata _name) external view returns (address) {
        return(candidateAddr[_name]);
    }

    function findWinners() public view returns (address[] memory winners, uint256 maxVotes) {
        maxVotes = 0;
        address[] memory tempWinners = new address[](candidates.length);
        uint256 winnerCount = 0;

        for (uint256 i = 0; i < candidates.length; i++) {
            uint256 currentVotes = votes[candidates[i]];
            if (currentVotes > maxVotes && currentVotes > 0) {
                maxVotes = currentVotes;
                winnerCount = 0;
                tempWinners[winnerCount] = candidates[i];
                winnerCount++;
            } else if (currentVotes == maxVotes) {
                tempWinners[winnerCount] = candidates[i];
                winnerCount++;
            }
        }

        winners = new address[](winnerCount);
        for (uint256 i = 0; i < winnerCount; i++) {
            winners[i] = tempWinners[i];
        }

        return (winners, maxVotes);
    }

    function callWinner() external {
        require(block.timestamp >= votingDeadline, "Voting hasn't ended yet");
        (address[] memory winners, ) = findWinners();

        emit VotingEnded(winners);
    }
}