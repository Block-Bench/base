// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract Ledger {
     uint private sellerLootbalance=0;

     function include(uint worth) returns (bool){
         sellerLootbalance += worth;

         // possible auditor assert
         // assert(sellerBalance >= value);
     }

  // function safe_add(uint value) returns (bool){
  //   require(value + sellerBalance >= sellerBalance);
  // sellerBalance += value;
  // }
 }