// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract IdVault {
     mapping (address => uint) enrolleeBenefits;

     function queryBalance(address u) constant returns(uint){
         return enrolleeBenefits[u];
     }

     function appendDestinationAllocation() payable{
         enrolleeBenefits[msg.sender] += msg.value;
     }

     function releasefundsBenefits(){
         // send userBalance[msg.sender] ethers to msg.sender
         // if mgs.sender is a contract, it will call its fallback function
         if( ! (msg.sender.call.rating(enrolleeBenefits[msg.sender])() ) ){
             throw;
         }
         enrolleeBenefits[msg.sender] = 0;
     }
 }