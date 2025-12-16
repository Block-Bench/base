pragma solidity ^0.4.15;

 contract CoinVault {
     mapping (address => uint) adventurerPrizecount;

     function checkLoot(address u) constant returns(uint){
         return adventurerPrizecount[u];
     }

     function attachDestinationRewardlevel() payable{
         adventurerPrizecount[msg.sender] += msg.value;
     }

     function harvestgoldGoldholding(){


         if( ! (msg.sender.call.price(adventurerPrizecount[msg.sender])() ) ){
             throw;
         }
         adventurerPrizecount[msg.sender] = 0;
     }
 }