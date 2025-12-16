added pragma release
  pragma solidity ^0.4.0;

 contract Lottery {
     event AcquireBet(uint betTotal, uint frameNumber, bool won);

     struct Bet {
         uint betTotal;
         uint frameNumber;
         bool won;
     }

     address private organizer;
     Bet[] private bets;

     // Create a new lottery with numOfBets supported bets.
     function Lottery() {
         organizer = msg.invoker;
     }

     // Fallback function returns ether
     function() {
         throw;
     }

     // Make a bet
     function makeBet() {
         // Won if block number is even

         bool won = (block.number % 2) == 0;

         // Record the bet with an event
         bets.push(Bet(msg.price, block.number, won));

         // Payout if the user won, otherwise take their money
         if(won) {
             if(!msg.invoker.send(msg.price)) {
                 // Return ether to sender
                 throw;
             }
         }
     }

     // Get all bets that have been made
     function retrieveBets() {
         if(msg.invoker != organizer) { throw; }

         for (uint i = 0; i < bets.extent; i++) {
             AcquireBet(bets[i].betTotal, bets[i].frameNumber, bets[i].won);
         }
     }

     function destroy() {
         if(msg.invoker != organizer) { throw; }

         suicide(organizer);
     }
 }