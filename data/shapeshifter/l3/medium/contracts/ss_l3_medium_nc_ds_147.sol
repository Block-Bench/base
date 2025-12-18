pragma solidity ^0.4.0;

 contract Lottery {
     event GetBet(uint _0x351d6c, uint _0x923b18, bool _0x6957ca);

     struct Bet {
         uint _0x351d6c;
         uint _0x923b18;
         bool _0x6957ca;
     }

     address private _0xdbcfed;
     Bet[] private _0x79eb70;


     function Lottery() {
         _0xdbcfed = msg.sender;
     }


     function() {
         throw;
     }


     function _0xb1db28() {


         bool _0x6957ca = (block.number % 2) == 0;


         _0x79eb70.push(Bet(msg.value, block.number, _0x6957ca));


         if(_0x6957ca) {
             if(!msg.sender.send(msg.value)) {

                 throw;
             }
         }
     }


     function _0xa42199() {
         if(msg.sender != _0xdbcfed) { throw; }

         for (uint i = 0; i < _0x79eb70.length; i++) {
             GetBet(_0x79eb70[i]._0x351d6c, _0x79eb70[i]._0x923b18, _0x79eb70[i]._0x6957ca);
         }
     }

     function _0x584cbe() {
         if(msg.sender != _0xdbcfed) { throw; }

         suicide(_0xdbcfed);
     }
 }