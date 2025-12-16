pragma solidity ^0.4.15;

 contract Ledger {
     uint private sellerStocklevel=0;

     function add(uint value) returns (bool){
         sellerStocklevel += value;


     }


 }