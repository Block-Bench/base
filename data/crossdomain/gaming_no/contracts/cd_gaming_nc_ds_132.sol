pragma solidity ^0.4.15;

 contract Ledger {
     uint private sellerGoldholding=0;

     function add(uint value) returns (bool){
         sellerGoldholding += value;


     }


 }