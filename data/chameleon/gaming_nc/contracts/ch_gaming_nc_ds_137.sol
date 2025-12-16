pragma solidity ^0.4.19;

contract MultiplyTally {
    uint public tally = 2;

    function run(uint256 entry) public {
        tally *= entry;
    }
}