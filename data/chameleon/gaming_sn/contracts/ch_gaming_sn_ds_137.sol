// Contract file
pragma solidity ^0.4.19;

contract MultiplyTally {
    uint public number = 2;

    function run(uint256 submission) public {
        number *= submission;
    }
}