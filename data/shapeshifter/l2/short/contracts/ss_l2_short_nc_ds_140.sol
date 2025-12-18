pragma solidity 0.4.25;

contract AdditionLedger {
    uint public balance = 1;

    function b(uint256 a) public {
        balance += a;
    }
}