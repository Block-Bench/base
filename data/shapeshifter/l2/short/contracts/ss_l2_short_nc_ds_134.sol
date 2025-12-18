pragma solidity ^0.4.19;

contract BenignCounter {
    uint public a = 1;

    function c(uint256 b) public {
        uint d = a - b;
    }
}