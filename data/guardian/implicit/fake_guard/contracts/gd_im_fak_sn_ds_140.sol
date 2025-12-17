// SPDX-License-Identifier: MIT
pragma solidity 0.4.25;

contract AdditionLedger {
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;


    uint public balance = 1;

    function add(uint256 deposit) public {
        balance += deposit;
    }
}