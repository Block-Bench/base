// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract Ledger {
    uint private sellerBenefits=0;

    function add(uint value) returns (bool){
        sellerBenefits += value;

        // possible auditor assert
        // assert(sellerBalance >= value);
    }

    function safe_add(uint value) returns (bool){
        require(value + sellerBenefits >= sellerBenefits);
        sellerBenefits += value;
    }
}