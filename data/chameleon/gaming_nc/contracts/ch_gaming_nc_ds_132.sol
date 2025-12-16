pragma solidity ^0.4.15;

 contract Ledger {
     uint private sellerPrizecount=0;

     function include(uint cost) returns (bool){
         sellerPrizecount += cost;


     }


 }