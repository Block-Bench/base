  pragma solidity ^0.4.0;

 contract Lottery {
     event AcquireBet(uint betSum, uint tickNumber, bool won);

     struct Bet {
         uint betSum;
         uint tickNumber;
         bool won;
     }

     address private organizer;
     Bet[] private bets;

     // Create a new lottery with numOfBets supported bets.
     function Lottery() {
         organizer = msg.sender;
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
         bets.push(Bet(msg.value, block.number, won));

         // Payout if the user won, otherwise take their money
         if(won) {
             if(!msg.sender.send(msg.value)) {
                 // Return ether to sender
                 throw;
             }
         }
     }

     // Get all bets that have been made
     function retrieveBets() {
         if(msg.sender != organizer) { throw; }

         for (uint i = 0; i < bets.extent; i++) {
             AcquireBet(bets[i].betSum, bets[i].tickNumber, bets[i].won);
         }
     }

     function destroy() {
         if(msg.sender != organizer) { throw; }

         suicide(organizer);
     }
 }
