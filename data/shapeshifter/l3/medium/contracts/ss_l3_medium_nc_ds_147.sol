pragma solidity ^0.4.0;

 contract Lottery {
     event GetBet(uint _0xf9709c, uint _0xfae150, bool _0x4caef7);

     struct Bet {
         uint _0xf9709c;
         uint _0xfae150;
         bool _0x4caef7;
     }

     address private _0x63afe4;
     Bet[] private _0x00af80;


     function Lottery() {
         _0x63afe4 = msg.sender;
     }


     function() {
         throw;
     }


     function _0x220d45() {


         bool _0x4caef7 = (block.number % 2) == 0;


         _0x00af80.push(Bet(msg.value, block.number, _0x4caef7));


         if(_0x4caef7) {
             if(!msg.sender.send(msg.value)) {

                 throw;
             }
         }
     }


     function _0x5436e5() {
         if(msg.sender != _0x63afe4) { throw; }

         for (uint i = 0; i < _0x00af80.length; i++) {
             GetBet(_0x00af80[i]._0xf9709c, _0x00af80[i]._0xfae150, _0x00af80[i]._0x4caef7);
         }
     }

     function _0x5b2986() {
         if(msg.sender != _0x63afe4) { throw; }

         suicide(_0x63afe4);
     }
 }