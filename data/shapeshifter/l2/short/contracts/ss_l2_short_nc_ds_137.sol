pragma solidity ^0.4.19;

contract MultiplyCounter {
    uint public a = 2;

    function c(uint256 b) public {
        a *= b;
    }
}