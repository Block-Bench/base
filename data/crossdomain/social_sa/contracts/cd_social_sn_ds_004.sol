// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract Ledger {
    uint private sellerKarma=0;

    function add(uint value) returns (bool){
        sellerKarma += value;

        // possible auditor assert
        // assert(sellerBalance >= value);
    }

    function safe_add(uint value) returns (bool){
        require(value + sellerKarma >= sellerKarma);
        sellerKarma += value;
    }
}