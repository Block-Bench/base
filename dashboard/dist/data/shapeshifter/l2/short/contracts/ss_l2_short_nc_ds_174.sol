pragma solidity ^0.4.0;

 contract Lotto {

     uint constant public j = 6800;


     uint constant public r = 100000000000000000;


     uint constant public s = 5000000000000000000;

     function g() constant returns(uint){ return j; }
     function k() constant returns(uint){ return r; }


     struct Round {
         address[] ab;
         uint ai;
         uint n;
         mapping(uint=>bool) aa;
         mapping(address=>uint) c;
     }
     mapping(uint => Round) ae;


     function m() constant returns (uint){


         return block.number/j;
     }

     function u(uint w,uint t) constant returns (bool){


         return ae[w].aa[t];
     }

     function i(uint w, uint t) constant returns(address){


         var d = b(w,t);

         if(d>block.number)
             return;


         var f = l(d);
         var e = f%ae[w].n;


         var q = uint256(0);

         for(var x = 0; x<ae[w].ab.length; x++){
             var ag = ae[w].ab[x];
             q+=ae[w].c[ag];

             if(q>e){
                 return ag;
             }
         }
     }

     function b(uint w,uint t) constant returns (uint){
         return ((w+1)*j)+t;
     }

     function h(uint w) constant returns(uint){
         var o = ae[w].ai/s;

         if(ae[w].ai%s>0)
             o++;

         return o;
     }

     function y(uint w) constant returns(uint){
         return ae[w].ai/h(w);
     }

     function ah(uint w, uint t){

         var o = h(w);

         if(t>=o)
             return;

         var d = b(w,t);

         if(d>block.number)
             return;

         if(ae[w].aa[t])
             return;


         var ad = i(w,t);
         var ac = y(w);

         ad.send(ac);

         ae[w].aa[t] = true;

     }

     function l(uint v) constant returns(uint){
         return uint(block.blockhash(v));
     }

     function z(uint w,address ag) constant returns (address[]){
         return ae[w].ab;
     }

     function a(uint w,address ag) constant returns (uint){
         return ae[w].c[ag];
     }

     function af(uint w) constant returns(uint){
         return ae[w].ai;
     }

     function() {


         var w = m();
         var value = msg.value-(msg.value%r);

         if(value==0) return;

         if(value<msg.value){
             msg.sender.send(msg.value-value);
         }


         var n = value/r;
         ae[w].n+=n;

         if(ae[w].c[msg.sender]==0){
             var p = ae[w].ab.length++;
             ae[w].ab[p] = msg.sender;
         }

         ae[w].c[msg.sender]+=n;
         ae[w].n+=n;


         ae[w].ai+=value;


     }

 }