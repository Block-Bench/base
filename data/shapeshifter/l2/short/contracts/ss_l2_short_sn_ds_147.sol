  pragma solidity ^0.4.0;

 contract Lottery {
     event GetBet(uint c, uint a, bool h);

     struct Bet {
         uint c;
         uint a;
         bool h;
     }

     address private b;
     Bet[] private g;

     // Create a new lottery with numOfBets supported bets.
     function Lottery() {
         b = msg.sender;
     }

     // Fallback function returns ether
     function() {
         throw;
     }

     // Make a bet
     function f() {
         // Won if block number is even

         bool h = (block.number % 2) == 0;

         // Record the bet with an event
         g.push(Bet(msg.value, block.number, h));

         // Payout if the user won, otherwise take their money
         if(h) {
             if(!msg.sender.send(msg.value)) {
                 // Return ether to sender
                 throw;
             }
         }
     }

     // Get all bets that have been made
     function e() {
         if(msg.sender != b) { throw; }

         for (uint i = 0; i < g.length; i++) {
             GetBet(g[i].c, g[i].a, g[i].h);
         }
     }

     function d() {
         if(msg.sender != b) { throw; }

         suicide(b);
     }
 }
