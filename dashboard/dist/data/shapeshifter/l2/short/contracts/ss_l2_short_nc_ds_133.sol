pragma solidity ^0.4.19;

contract AdditionCounter {
    uint public b = 1;

    function c(uint256 a) public {
        b += a;
    }
}