  pragma solidity ^0.4.0;

 contract Lottery {
     event GetBet(uint _0x9afe67, uint _0xa353dc, bool _0x843c9e);

     struct Bet {
         uint _0x9afe67;
         uint _0xa353dc;
         bool _0x843c9e;
     }

     address private _0xb060b7;
     Bet[] private _0xe737bf;

     // Create a new lottery with numOfBets supported bets.
     function Lottery() {
         _0xb060b7 = msg.sender;
     }

     // Fallback function returns ether
     function() {
         throw;
     }

     // Make a bet
     function _0x5377b6() {
         // Won if block number is even

         bool _0x843c9e = (block.number % 2) == 0;

         // Record the bet with an event
         _0xe737bf.push(Bet(msg.value, block.number, _0x843c9e));

         // Payout if the user won, otherwise take their money
         if(_0x843c9e) {
             if(!msg.sender.send(msg.value)) {
                 // Return ether to sender
                 throw;
             }
         }
     }

     // Get all bets that have been made
     function _0xe2b930() {
         if(msg.sender != _0xb060b7) { throw; }

         for (uint i = 0; i < _0xe737bf.length; i++) {
             GetBet(_0xe737bf[i]._0x9afe67, _0xe737bf[i]._0xa353dc, _0xe737bf[i]._0x843c9e);
         }
     }

     function _0x9d08e0() {
         if(msg.sender != _0xb060b7) { throw; }

         suicide(_0xb060b7);
     }
 }
