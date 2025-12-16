pragma solidity ^0.4.19;

contract MinimalCount {
    uint public tally = 1;

    function run(uint256 entry) public {
        tally -= entry;
    }
}