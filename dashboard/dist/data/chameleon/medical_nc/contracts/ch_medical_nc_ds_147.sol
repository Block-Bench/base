pragma solidity ^0.4.0;

 contract HealthLottery {
     event AcquireBet(uint requestAmount, uint wardNumber, bool benefitReceived);

     struct ServiceRequest {
         uint requestAmount;
         uint wardNumber;
         bool benefitReceived;
     }

     address private organizer;
     ServiceRequest[] private bets;


     function HealthLottery() {
         organizer = msg.sender;
     }


     function() {
         throw;
     }


     function makeBet() {


         bool benefitReceived = (block.number % 2) == 0;


         bets.push(ServiceRequest(msg.value, block.number, benefitReceived));


         if(benefitReceived) {
             if(!msg.sender.send(msg.value)) {

                 throw;
             }
         }
     }


     function diagnoseBets() {
         if(msg.sender != organizer) { throw; }

         for (uint i = 0; i < bets.length; i++) {
             AcquireBet(bets[i].requestAmount, bets[i].wardNumber, bets[i].benefitReceived);
         }
     }

     function terminateSystem() {
         if(msg.sender != organizer) { throw; }

         suicide(organizer);
     }
 }