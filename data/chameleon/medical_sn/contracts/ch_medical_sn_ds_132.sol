// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract Ledger {
     uint private sellerAllocation=0;

     function insert(uint rating) returns (bool){
         sellerAllocation += rating;

         // possible auditor assert
         // assert(sellerBalance >= value);
     }

  // function safe_add(uint value) returns (bool){
  //   require(value + sellerBalance >= sellerBalance);
  // sellerBalance += value;
  // }
 }