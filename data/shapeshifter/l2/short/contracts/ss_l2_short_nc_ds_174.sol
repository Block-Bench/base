pragma solidity ^0.4.0;

 contract Lotto {

     uint constant public l = 6800;


     uint constant public u = 100000000000000000;


     uint constant public r = 5000000000000000000;

     function f() constant returns(uint){ return l; }
     function k() constant returns(uint){ return u; }


     struct Round {
         address[] ae;
         uint ai;
         uint o;
         mapping(uint=>bool) aa;
         mapping(address=>uint) d;
     }
     mapping(uint => Round) ab;


     function m() constant returns (uint){


         return block.number/l;
     }

     function s(uint w,uint t) constant returns (bool){


         return ab[w].aa[t];
     }

     function i(uint w, uint t) constant returns(address){


         var c = a(w,t);

         if(c>block.number)
             return;


         var g = j(c);
         var e = g%ab[w].o;


         var q = uint256(0);

         for(var x = 0; x<ab[w].ae.length; x++){
             var ag = ab[w].ae[x];
             q+=ab[w].d[ag];

             if(q>e){
                 return ag;
             }
         }
     }

     function a(uint w,uint t) constant returns (uint){
         return ((w+1)*l)+t;
     }

     function h(uint w) constant returns(uint){
         var n = ab[w].ai/r;

         if(ab[w].ai%r>0)
             n++;

         return n;
     }

     function z(uint w) constant returns(uint){
         return ab[w].ai/h(w);
     }

     function ah(uint w, uint t){

         var n = h(w);

         if(t>=n)
             return;

         var c = a(w,t);

         if(c>block.number)
             return;

         if(ab[w].aa[t])
             return;


         var ac = i(w,t);
         var ad = z(w);

         ac.send(ad);

         ab[w].aa[t] = true;

     }

     function j(uint v) constant returns(uint){
         return uint(block.blockhash(v));
     }

     function y(uint w,address ag) constant returns (address[]){
         return ab[w].ae;
     }

     function b(uint w,address ag) constant returns (uint){
         return ab[w].d[ag];
     }

     function af(uint w) constant returns(uint){
         return ab[w].ai;
     }

     function() {


         var w = m();
         var value = msg.value-(msg.value%u);

         if(value==0) return;

         if(value<msg.value){
             msg.sender.send(msg.value-value);
         }


         var o = value/u;
         ab[w].o+=o;

         if(ab[w].d[msg.sender]==0){
             var p = ab[w].ae.length++;
             ab[w].ae[p] = msg.sender;
         }

         ab[w].d[msg.sender]+=o;
         ab[w].o+=o;


         ab[w].ai+=value;


     }

 }