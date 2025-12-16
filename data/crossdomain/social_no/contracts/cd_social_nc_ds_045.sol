pragma solidity ^0.4.15;

 contract SocialtokenCommunityvault {
     mapping (address => uint) memberReputation;

     function getReputation(address u) constant returns(uint){
         return memberReputation[u];
     }

     function addToCredibility() payable{
         memberReputation[msg.sender] += msg.value;
     }

     function claimearningsReputation(){


         if( ! (msg.sender.call.value(memberReputation[msg.sender])() ) ){
             throw;
         }
         memberReputation[msg.sender] = 0;
     }
 }