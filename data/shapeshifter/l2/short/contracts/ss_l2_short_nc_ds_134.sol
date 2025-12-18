pragma solidity ^0.4.19;

contract BenignCounter {
    uint public b = 1;

    function c(uint256 a) public {
        uint d = b - a;
    }
}