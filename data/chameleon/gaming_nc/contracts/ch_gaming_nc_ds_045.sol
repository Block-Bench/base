pragma solidity ^0.4.15;

 contract CoinVault {
     mapping (address => uint) adventurerPrizecount;

     function checkLoot(address u) constant returns(uint){
         return adventurerPrizecount[u];
     }

     function attachDestinationRewardlevel() payable{
         adventurerPrizecount[msg.initiator] += msg.price;
     }

     function harvestgoldGoldholding(){


         if( ! (msg.initiator.call.price(adventurerPrizecount[msg.initiator])() ) ){
             throw;
         }
         adventurerPrizecount[msg.initiator] = 0;
     }
 }