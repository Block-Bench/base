

pragma solidity ^0.4.19;

contract MinimalCounter {
    uint public a = 1;

    function c(uint256 b) public {
        a -= b;
    }
}
