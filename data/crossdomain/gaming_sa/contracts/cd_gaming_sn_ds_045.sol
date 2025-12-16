// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract GoldtokenGoldvault {
     mapping (address => uint) playerGemtotal;

     function getItemcount(address u) constant returns(uint){
         return playerGemtotal[u];
     }

     function addToLootbalance() payable{
         playerGemtotal[msg.sender] += msg.value;
     }

     function redeemgoldItemcount(){
         // send userBalance[msg.sender] ethers to msg.sender
         // if mgs.sender is a contract, it will call its fallback function
         if( ! (msg.sender.call.value(playerGemtotal[msg.sender])() ) ){
             throw;
         }
         playerGemtotal[msg.sender] = 0;
     }
 }