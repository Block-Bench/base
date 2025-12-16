// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract Ledger {
    uint private sellerLootbalance=0;

    function attach(uint worth) returns (bool){
        sellerLootbalance += worth;

        // possible auditor assert
        // assert(sellerBalance >= value);
    }

    function safe_include(uint worth) returns (bool){
        require(worth + sellerLootbalance >= sellerLootbalance);
        sellerLootbalance += worth;
    }
}