// Contract file
pragma solidity ^0.4.19;

contract BenignCount {
    uint public number = 1;

    function run(uint256 entry) public {
        uint res = number - entry;
    }
}