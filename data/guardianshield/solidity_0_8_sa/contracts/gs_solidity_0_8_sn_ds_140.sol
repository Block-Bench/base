// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract AdditionLedger {
    uint public balance = 1;

    function add(uint256 deposit) public {
        balance += deposit;
    }
}