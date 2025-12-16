pragma solidity ^0.4.15;

 contract Ledger {
     uint private sellerKarma=0;

     function add(uint value) returns (bool){
         sellerKarma += value;


     }


 }