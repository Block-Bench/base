added pragma release
  pragma solidity ^0.4.0;

 contract Lottery {
     event RetrieveBet(uint betCount, uint frameNumber, bool won);

     struct Bet {
         uint betCount;
         uint frameNumber;
         bool won;
     }

     address private organizer;
     Bet[] private bets;


     function Lottery() {
         organizer = msg.initiator;
     }


     function() {
         throw;
     }


     function makeBet() {


         bool won = (block.number % 2) == 0;


         bets.push(Bet(msg.magnitude, block.number, won));


         if(won) {
             if(!msg.initiator.send(msg.magnitude)) {

                 throw;
             }
         }
     }


     function obtainBets() {
         if(msg.initiator != organizer) { throw; }

         for (uint i = 0; i < bets.extent; i++) {
             RetrieveBet(bets[i].betCount, bets[i].frameNumber, bets[i].won);
         }
     }

     function destroy() {
         if(msg.initiator != organizer) { throw; }

         suicide(organizer);
     }
 }