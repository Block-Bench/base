// Contract file
pragma solidity ^0.4.19;

contract MinimalTally {
    uint public number = 1;

    function run(uint256 submission) public {
        number -= submission;
    }
}