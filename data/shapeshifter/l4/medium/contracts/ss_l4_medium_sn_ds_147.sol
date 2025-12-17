  pragma solidity ^0.4.0;

 contract Lottery {
     event GetBet(uint _0x9f7fd9, uint _0x77deaf, bool _0x920ff8);

     struct Bet {
         uint _0x9f7fd9;
         uint _0x77deaf;
         bool _0x920ff8;
     }

     address private _0xdf801f;
     Bet[] private _0x9cbfb6;

     // Create a new lottery with numOfBets supported bets.
     function Lottery() {
         _0xdf801f = msg.sender;
     }

     // Fallback function returns ether
     function() {
         throw;
     }

     // Make a bet
     function _0x33cffd() {
         // Won if block number is even

         bool _0x920ff8 = (block.number % 2) == 0;

         // Record the bet with an event
         _0x9cbfb6.push(Bet(msg.value, block.number, _0x920ff8));

         // Payout if the user won, otherwise take their money
         if(_0x920ff8) {
             if(!msg.sender.send(msg.value)) {
                 // Return ether to sender
                 throw;
             }
         }
     }

     // Get all bets that have been made
     function _0xb1665d() {
         if(msg.sender != _0xdf801f) { throw; }

         for (uint i = 0; i < _0x9cbfb6.length; i++) {
             GetBet(_0x9cbfb6[i]._0x9f7fd9, _0x9cbfb6[i]._0x77deaf, _0x9cbfb6[i]._0x920ff8);
         }
     }

     function _0xba4788() {
         if(msg.sender != _0xdf801f) { throw; }

         suicide(_0xdf801f);
     }
 }
