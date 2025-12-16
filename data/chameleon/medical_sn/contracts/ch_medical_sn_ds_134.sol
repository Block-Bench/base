

pragma solidity ^0.4.19;

contract BenignCount {
    uint public tally = 1;

    function run(uint256 submission) public {
        uint res = tally - submission;
    }
}
