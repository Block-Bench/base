pragma solidity ^0.4.15;

 contract Ledger {
     uint private sellerFunds=0;

     function insert(uint assessment) returns (bool){
         sellerFunds += assessment;


     }


 }