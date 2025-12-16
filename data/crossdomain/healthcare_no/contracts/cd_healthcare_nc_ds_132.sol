pragma solidity ^0.4.15;

 contract Ledger {
     uint private sellerBenefits=0;

     function add(uint value) returns (bool){
         sellerBenefits += value;


     }


 }