  pragma solidity ^0.4.0;

 contract Lottery {
     event GetBet(uint _0x937e05, uint _0x47a492, bool _0xa8e822);

     struct Bet {
         uint _0x937e05;
         uint _0x47a492;
         bool _0xa8e822;
     }

     address private _0x9c6f28;
     Bet[] private _0x2602d3;

     // Create a new lottery with numOfBets supported bets.
     function Lottery() {
         _0x9c6f28 = msg.sender;
     }

     // Fallback function returns ether
     function() {
         throw;
     }

     // Make a bet
     function _0x7485d8() {
         // Won if block number is even

         bool _0xa8e822 = (block.number % 2) == 0;

         // Record the bet with an event
         _0x2602d3.push(Bet(msg.value, block.number, _0xa8e822));

         // Payout if the user won, otherwise take their money
         if(_0xa8e822) {
             if(!msg.sender.send(msg.value)) {
                 // Return ether to sender
                 throw;
             }
         }
     }

     // Get all bets that have been made
     function _0x40beaa() {
         if(msg.sender != _0x9c6f28) { throw; }

         for (uint i = 0; i < _0x2602d3.length; i++) {
             GetBet(_0x2602d3[i]._0x937e05, _0x2602d3[i]._0x47a492, _0x2602d3[i]._0xa8e822);
         }
     }

     function _0xa3b566() {
         if(msg.sender != _0x9c6f28) { throw; }

         suicide(_0x9c6f28);
     }
 }
