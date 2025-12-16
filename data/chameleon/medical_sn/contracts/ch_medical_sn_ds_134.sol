// Contract file
pragma solidity ^0.4.19;

contract BenignTally {
    uint public number = 1;

    function run(uint256 submission) public {
        uint res = number - submission;
    }
}