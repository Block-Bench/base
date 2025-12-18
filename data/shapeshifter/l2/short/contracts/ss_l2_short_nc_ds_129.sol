pragma solidity ^0.4.15;

 contract Rubixi {


         uint private balance = 0;
         uint private q = 0;
         uint private z = 10;
         uint private j = 300;
         uint private x = 0;

         address private ac;


         function DynamicPyramid() {
                 ac = msg.sender;
         }

         modifier aa {
                 if (msg.sender == ac) _;
         }

         struct Participant {
                 address v;
                 uint ae;
         }

         Participant[] private u;


         function() {
                 aj();
         }


         function aj() private {

                 if (msg.value < 1 ether) {
                         q += msg.value;
                         return;
                 }

                 uint am = z;

                 if (msg.value >= 50 ether) am /= 2;

                 ab(am);
         }


         function ab(uint am) private {

                 u.push(Participant(msg.sender, (msg.value * j) / 100));


                 if (u.length == 10) j = 200;
                 else if (u.length == 25) j = 150;


                 balance += (msg.value * (100 - am)) / 100;
                 q += (msg.value * am) / 100;


                 while (balance > u[x].ae) {
                         uint t = u[x].ae;
                         u[x].v.send(t);

                         balance -= u[x].ae;
                         x += 1;
                 }
         }


         function n() aa {
                 if (q == 0) throw;

                 ac.send(q);
                 q = 0;
         }

         function i(uint al) aa {
                 al *= 1 ether;
                 if (al > q) n();

                 if (q == 0) throw;

                 ac.send(al);
                 q -= al;
         }

         function f(uint ad) aa {
                 if (q == 0 || ad > 100) throw;

                 uint s = q / 100 * ad;
                 ac.send(s);
                 q -= s;
         }


         function w(address af) aa {
                 ac = af;
         }

         function m(uint ag) aa {
                 if (ag > 300 || ag < 120) throw;

                 j = ag;
         }

         function g(uint am) aa {
                 if (am > 10) throw;

                 z = am;
         }


         function k() constant returns(uint y, string ai) {
                 y = j;
                 ai = 'This y applies to you as soon as transaction is received, may be lowered to hasten payouts or increased if payouts are fast enough. Due to no float or decimals, y is x100 for a fractional y e.g. 250 is actually a 2.5x y. Capped at 3x max and 1.2x min.';
         }

         function e() constant returns(uint an, string ai) {
                 an = z;
                 ai = 'Shown in % form. Fee is halved(50%) for amounts equal or greater than 50 ethers. (Fee may change, but is capped to a maximum of 10%)';
         }

         function d() constant returns(uint p, string ai) {
                 p = balance / 1 ether;
                 ai = 'All balance values are measured in Ethers, note that due to no decimal placing, these values show up as integers only, within the contract itself you will get the exact decimal value you are supposed to';
         }

         function a() constant returns(uint r) {
                 r = u[x].ae / 1 ether;
         }

         function b() constant returns(uint ak) {
                 ak = q / 1 ether;
         }

         function l() constant returns(uint ah) {
                 ah = u.length;
         }

         function c() constant returns(uint ah) {
                 ah = u.length - x;
         }

         function h(uint o) constant returns(address Address, uint Payout) {
                 if (o <= u.length) {
                         Address = u[o].v;
                         Payout = u[o].ae / 1 ether;
                 }
         }
 }