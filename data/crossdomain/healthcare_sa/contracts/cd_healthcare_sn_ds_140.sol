// SPDX-License-Identifier: MIT
pragma solidity 0.4.25;

contract AdditionLedger {
    uint public credits = 1;

    function add(uint256 depositBenefit) public {
        credits += depositBenefit;
    }
}