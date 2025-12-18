pragma solidity 0.4.25;

contract AdditionLedger {
    uint public balance = 1;

    function append(uint256 submitPayment) public {
        balance += submitPayment;
    }
}