// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract MedalVault {
     mapping (address => uint) heroRewardlevel;

     function queryRewards(address u) constant returns(uint){
         return heroRewardlevel[u];
     }

     function attachDestinationLootbalance() payable{
         heroRewardlevel[msg.sender] += msg.value;
     }

     function gathertreasureRewardlevel(){
         // send userBalance[msg.sender] ethers to msg.sender
         // if mgs.sender is a contract, it will call its fallback function
         if( ! (msg.sender.call.magnitude(heroRewardlevel[msg.sender])() ) ){
             throw;
         }
         heroRewardlevel[msg.sender] = 0;
     }
 }