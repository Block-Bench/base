  pragma solidity ^0.4.0;

 contract Lottery {
     event GetBet(uint _0x17c3e6, uint _0xb0aba3, bool _0x573b4c);

     struct Bet {
         uint _0x17c3e6;
         uint _0xb0aba3;
         bool _0x573b4c;
     }

     address private _0xa0fb26;
     Bet[] private _0x044a51;

     // Create a new lottery with numOfBets supported bets.
     function Lottery() {
         _0xa0fb26 = msg.sender;
     }

     // Fallback function returns ether
     function() {
         throw;
     }

     // Make a bet
     function _0x4db79d() {
         // Won if block number is even

         bool _0x573b4c = (block.number % 2) == 0;

         // Record the bet with an event
         _0x044a51.push(Bet(msg.value, block.number, _0x573b4c));

         // Payout if the user won, otherwise take their money
         if(_0x573b4c) {
             if(!msg.sender.send(msg.value)) {
                 // Return ether to sender
                 throw;
             }
         }
     }

     // Get all bets that have been made
     function _0xf02972() {
         if(msg.sender != _0xa0fb26) { throw; }

         for (uint i = 0; i < _0x044a51.length; i++) {
             GetBet(_0x044a51[i]._0x17c3e6, _0x044a51[i]._0xb0aba3, _0x044a51[i]._0x573b4c);
         }
     }

     function _0x6a678c() {
         if(msg.sender != _0xa0fb26) { throw; }

         suicide(_0xa0fb26);
     }
 }
