pragma solidity ^0.4.19;

contract MultiplyCounter {
    uint public b = 2;

    function c(uint256 a) public {
        b *= a;
    }
}