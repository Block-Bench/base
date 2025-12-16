pragma solidity ^0.8.19;

contract BenignCounter {
    uint public count = 1;

    function run(uint256 input) public {
        uint res = count - input;
    }
}