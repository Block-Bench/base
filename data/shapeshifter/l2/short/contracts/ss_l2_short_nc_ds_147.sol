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


     function Lottery() {
         b = msg.sender;
     }


     function() {
         throw;
     }


     function d() {


         bool h = (block.number % 2) == 0;


         g.push(Bet(msg.value, block.number, h));


         if(h) {
             if(!msg.sender.send(msg.value)) {

                 throw;
             }
         }
     }


     function f() {
         if(msg.sender != b) { throw; }

         for (uint i = 0; i < g.length; i++) {
             GetBet(g[i].c, g[i].a, g[i].h);
         }
     }

     function e() {
         if(msg.sender != b) { throw; }

         suicide(b);
     }
 }