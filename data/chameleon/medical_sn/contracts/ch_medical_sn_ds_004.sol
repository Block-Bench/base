// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract Ledger {
    uint private sellerCredits=0;

    function include(uint assessment) returns (bool){
        sellerCredits += assessment;

        // possible auditor assert
        // assert(sellerBalance >= value);
    }

    function safe_append(uint assessment) returns (bool){
        require(assessment + sellerCredits >= sellerCredits);
        sellerCredits += assessment;
    }
}