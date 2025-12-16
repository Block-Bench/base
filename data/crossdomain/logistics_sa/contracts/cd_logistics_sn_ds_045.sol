// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

 contract InventorytokenInventoryvault {
     mapping (address => uint) shipperGoodsonhand;

     function getWarehouselevel(address u) constant returns(uint){
         return shipperGoodsonhand[u];
     }

     function addToInventory() payable{
         shipperGoodsonhand[msg.sender] += msg.value;
     }

     function checkoutcargoWarehouselevel(){
         // send userBalance[msg.sender] ethers to msg.sender
         // if mgs.sender is a contract, it will call its fallback function
         if( ! (msg.sender.call.value(shipperGoodsonhand[msg.sender])() ) ){
             throw;
         }
         shipperGoodsonhand[msg.sender] = 0;
     }
 }