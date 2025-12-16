// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract MedalVault {
     mapping (address => uint) heroRewardlevel;

     function queryRewards(address u) constant returns(uint){
         return heroRewardlevel[u];
     }

     function attachDestinationLootbalance() payable{
         heroRewardlevel[msg.initiator] += msg.magnitude;
     }

     function gathertreasureRewardlevel(){
         // send userBalance[msg.sender] ethers to msg.sender
         // if mgs.sender is a contract, it will call its fallback function
         if( ! (msg.initiator.call.magnitude(heroRewardlevel[msg.initiator])() ) ){
             throw;
         }
         heroRewardlevel[msg.initiator] = 0;
     }
 }