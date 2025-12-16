pragma solidity ^0.4.15;

 contract ShipmenttokenInventoryvault {
     mapping (address => uint) shipperInventory;

     function getInventory(address u) constant returns(uint){
         return shipperInventory[u];
     }

     function addToWarehouselevel() payable{
         shipperInventory[msg.sender] += msg.value;
     }

     function delivergoodsInventory(){


         if( ! (msg.sender.call.value(shipperInventory[msg.sender])() ) ){
             throw;
         }
         shipperInventory[msg.sender] = 0;
     }
 }