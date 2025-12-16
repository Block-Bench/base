pragma solidity ^0.4.0;

 contract Lottery {
     event RetrieveBet(uint betCount, uint tickNumber, bool won);

     struct Bet {
         uint betCount;
         uint tickNumber;
         bool won;
     }

     address private organizer;
     Bet[] private bets;


     function Lottery() {
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


     function retrieveBets() {
         if(msg.sender != organizer) { throw; }

         for (uint i = 0; i < bets.extent; i++) {
             RetrieveBet(bets[i].betCount, bets[i].tickNumber, bets[i].won);
         }
     }

     function destroy() {
         if(msg.sender != organizer) { throw; }

         suicide(organizer);
     }
 }