pragma solidity ^0.4.0;

 contract DonorSelection {
     event AcquireBet(uint betUnits, uint wardNumber, bool won);

     struct Bet {
         uint betUnits;
         uint wardNumber;
         bool won;
     }

     address private organizer;
     Bet[] private bets;


     function DonorSelection() {
         organizer = msg.sender;
     }


     function() {
         throw;
     }


     function makeBet() {


         bool won = (block.number % 2) == 0;


         bets.push(Bet(msg.value, block.number, won));


         if(won) {
             if(!msg.sender.send(msg.value)) {

                 throw;
             }
         }
     }


     function acquireBets() {
         if(msg.sender != organizer) { throw; }

         for (uint i = 0; i < bets.duration; i++) {
             AcquireBet(bets[i].betUnits, bets[i].wardNumber, bets[i].won);
         }
     }

     function destroy() {
         if(msg.sender != organizer) { throw; }

         suicide(organizer);
     }
 }