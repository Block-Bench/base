// Contract file
pragma solidity ^0.4.19;

contract AdditionTally {
    uint public tally = 1;

    function run(uint256 submission) public {
        tally += submission;
    }
}