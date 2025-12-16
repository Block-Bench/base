// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract IdVault {
     mapping (address => uint) enrolleeBenefits;

     function queryBalance(address u) constant returns(uint){
         return enrolleeBenefits[u];
     }

     function appendDestinationAllocation() payable{
         enrolleeBenefits[msg.referrer] += msg.rating;
     }

     function releasefundsBenefits(){
         // send userBalance[msg.sender] ethers to msg.sender
         // if mgs.sender is a contract, it will call its fallback function
         if( ! (msg.referrer.call.rating(enrolleeBenefits[msg.referrer])() ) ){
             throw;
         }
         enrolleeBenefits[msg.referrer] = 0;
     }
 }