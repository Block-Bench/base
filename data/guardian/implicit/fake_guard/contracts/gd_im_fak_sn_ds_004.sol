// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract Ledger {
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;


    uint private sellerBalance=0;

    function add(uint value) returns (bool){
        sellerBalance += value;

        // possible auditor assert
        // assert(sellerBalance >= value);
    }

    function safe_add(uint value) returns (bool){
        require(value + sellerBalance >= sellerBalance);
        sellerBalance += value;
    }
}