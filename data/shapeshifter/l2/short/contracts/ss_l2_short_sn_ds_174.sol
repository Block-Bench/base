pragma solidity ^0.4.0;

 contract Lotto {

     uint constant public j = 6800;
     // there are an infinite number of rounds (just like a real lottery that takes place every week). `blocksPerRound` decides how many blocks each round will last. 6800 is around a day.

     uint constant public t = 100000000000000000;
     // the cost of each ticket is .1 ether.

     uint constant public q = 5000000000000000000;

     function g() constant returns(uint){ return j; }
     function l() constant returns(uint){ return t; }
     //accessors for constants

     struct Round {
         address[] af;
         uint ai;
         uint n;
         mapping(uint=>bool) aa;
         mapping(address=>uint) d;
     }
     mapping(uint => Round) ac;
     //the contract maintains a mapping of rounds. Each round maintains a list of tickets, the total amount of the pot, and whether or not the round was "cashed". "Cashing" is the act of paying out the pot to the winner.

     function m() constant returns (uint){
         //The round index tells us which round we're on. For example if we're on block 24, we're on round 2. Division in Solidity automatically rounds down, so we don't need to worry about decimals.

         return block.number/j;
     }

     function u(uint w,uint r) constant returns (bool){
         //Determine if a given.

         return ac[w].aa[r];
     }

     function h(uint w, uint r) constant returns(address){
         //note this function only calculates the winners. It does not do any state changes and therefore does not include various validitiy checks

         var c = b(w,r);

         if(c>block.number)
             return;
         //We can't decided the winner if the round isn't over yet

         var f = k(c);
         var e = f%ac[w].n;
         //We perform a modulus of the blockhash to determine the winner

         var s = uint256(0);

         for(var v = 0; v<ac[w].af.length; v++){
             var ag = ac[w].af[v];
             s+=ac[w].d[ag];

             if(s>e){
                 return ag;
             }
         }
     }

     function b(uint w,uint r) constant returns (uint){
         return ((w+1)*j)+r;
     }

     function i(uint w) constant returns(uint){
         var o = ac[w].ai/q;

         if(ac[w].ai%q>0)
             o++;

         return o;
     }

     function z(uint w) constant returns(uint){
         return ac[w].ai/i(w);
     }

     function ah(uint w, uint r){

         var o = i(w);

         if(r>=o)
             return;

         var c = b(w,r);

         if(c>block.number)
             return;

         if(ac[w].aa[r])
             return;
         //Subpots can only be cashed once. This is to prevent double payouts

         var ad = h(w,r);
         var ae = z(w);

         ad.send(ae);

         ac[w].aa[r] = true;
         //Mark the round as cashed
     }

     function k(uint x) constant returns(uint){
         return uint(block.blockhash(x));
     }

     function y(uint w,address ag) constant returns (address[]){
         return ac[w].af;
     }

     function a(uint w,address ag) constant returns (uint){
         return ac[w].d[ag];
     }

     function ab(uint w) constant returns(uint){
         return ac[w].ai;
     }

     function() {
         //this is the function that gets called when people send money to the contract.

         var w = m();
         var value = msg.value-(msg.value%t);

         if(value==0) return;

         if(value<msg.value){
             msg.sender.send(msg.value-value);
         }
         //no partial tickets, send a partial refund

         var n = value/t;
         ac[w].n+=n;

         if(ac[w].d[msg.sender]==0){
             var p = ac[w].af.length++;
             ac[w].af[p] = msg.sender;
         }

         ac[w].d[msg.sender]+=n;
         ac[w].n+=n;
         //keep track of the total tickets

         ac[w].ai+=value;
         //keep track of the total pot

     }

 }
