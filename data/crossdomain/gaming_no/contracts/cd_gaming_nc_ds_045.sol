pragma solidity ^0.4.15;

 contract QuesttokenGoldvault {
     mapping (address => uint) playerLootbalance;

     function getLootbalance(address u) constant returns(uint){
         return playerLootbalance[u];
     }

     function addToItemcount() payable{
         playerLootbalance[msg.sender] += msg.value;
     }

     function retrieveitemsLootbalance(){


         if( ! (msg.sender.call.value(playerLootbalance[msg.sender])() ) ){
             throw;
         }
         playerLootbalance[msg.sender] = 0;
     }
 }