pragma solidity ^0.4.19;

contract BenignTally {
    uint public number = 1;

    function run(uint256 intake) public {
        uint res = number - intake;
    }
}