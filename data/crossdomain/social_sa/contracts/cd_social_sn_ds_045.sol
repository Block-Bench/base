// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract ReputationtokenCommunityvault {
     mapping (address => uint) memberStanding;

     function getCredibility(address u) constant returns(uint){
         return memberStanding[u];
     }

     function addToReputation() payable{
         memberStanding[msg.sender] += msg.value;
     }

     function redeemkarmaCredibility(){
         // send userBalance[msg.sender] ethers to msg.sender
         // if mgs.sender is a contract, it will call its fallback function
         if( ! (msg.sender.call.value(memberStanding[msg.sender])() ) ){
             throw;
         }
         memberStanding[msg.sender] = 0;
     }
 }