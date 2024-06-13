// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingFactory {
    address[] public votingContracts;

    event VotingContractCreated(address votingContract);

    function createVoting(string[] memory candidateNames) public returns (address) {
        Voting newVoting = new Voting(candidateNames, msg.sender);
        votingContracts.push(address(newVoting));
        emit VotingContractCreated(address(newVoting));
        return address(newVoting);
    }

    function getVotingContracts() public view returns (address[] memory) {
        return votingContracts;
    }
}

// Голосувальний контракт
contract Voting {
    mapping(string => uint256) public votesReceived;
    string[] public candidateList;
    mapping(address => bool) public voters;
    mapping(address => bool) public authorizedVoters;
    address public owner;
    bool public resultsAvailable;

    event VoterAuthorized(address voter);
    event VoteCasted(address voter, string candidate);
    event ResultsOpened();

    constructor(string[] memory candidateNames, address creator) {
        candidateList = candidateNames;
        owner = creator;
        resultsAvailable = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function getAllCandidates() public view returns (string[] memory) {
    return candidateList;
    }

    function authorizeVoter(address voter) public onlyOwner {
        authorizedVoters[voter] = true;
        emit VoterAuthorized(voter);
    }

    function openResults() public onlyOwner {
        resultsAvailable = true;
        emit ResultsOpened();
    }

    function voteForCandidate(string memory candidate) public {
        require(authorizedVoters[msg.sender], "You are not authorized to vote");
        require(validCandidate(candidate), "Candidate not found");
        require(!voters[msg.sender], "You have already voted");
        votesReceived[candidate] += 1;
        voters[msg.sender] = true;
        emit VoteCasted(msg.sender, candidate);
    }

    function validCandidate(string memory candidate) public view returns (bool) {
        return _validCandidate(candidate);
    }

    function totalVotesFor(string memory candidate) public view returns (uint256) {
        require(resultsAvailable, "Results are not available yet");
        require(_validCandidate(candidate), "Candidate not found");
        return votesReceived[candidate];
    }

    function _validCandidate(string memory candidate) internal view returns (bool) {
        for (uint i = 0; i < candidateList.length; i++) {
            if (keccak256(abi.encodePacked(candidateList[i])) == keccak256(abi.encodePacked(candidate))) {
                return true;
            }
        }
        return false;
    }
}
