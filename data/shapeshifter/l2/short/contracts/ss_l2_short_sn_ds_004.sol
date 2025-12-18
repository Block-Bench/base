// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract Ledger {
    uint private a=0;

    function c(uint value) returns (bool){
        a += value;

        // possible auditor assert
        // assert(sellerBalance >= value);
    }

    function b(uint value) returns (bool){
        require(value + a >= a);
        a += value;
    }
}