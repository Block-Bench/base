// SPDX-License-Identifier: MIT
pragma solidity 0.4.25;

contract AdditionLedger {
    uint public balance = 1;

    function include(uint256 submitPayment) public {
        balance += submitPayment;
    }
}