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

         modifier ab {
                 if (msg.sender == ac) _;
         }

         struct Participant {
                 address t;
                 uint ad;
         }

         Participant[] private v;


         function() {
                 ai();
         }


         function ai() private {

                 if (msg.value < 1 ether) {
                         q += msg.value;
                         return;
                 }

                 uint aj = z;

                 if (msg.value >= 50 ether) aj /= 2;

                 aa(aj);
         }


         function aa(uint aj) private {

                 v.push(Participant(msg.sender, (msg.value * j) / 100));


                 if (v.length == 10) j = 200;
                 else if (v.length == 25) j = 150;


                 balance += (msg.value * (100 - aj)) / 100;
                 q += (msg.value * aj) / 100;


                 while (balance > v[x].ad) {
                         uint u = v[x].ad;
                         v[x].t.send(u);

                         balance -= v[x].ad;
                         x += 1;
                 }
         }


         function p() ab {
                 if (q == 0) throw;

                 ac.send(q);
                 q = 0;
         }

         function i(uint am) ab {
                 am *= 1 ether;
                 if (am > q) p();

                 if (q == 0) throw;

                 ac.send(am);
                 q -= am;
         }

         function f(uint af) ab {
                 if (q == 0 || af > 100) throw;

                 uint r = q / 100 * af;
                 ac.send(r);
                 q -= r;
         }


         function w(address ae) ab {
                 ac = ae;
         }

         function m(uint ag) ab {
                 if (ag > 300 || ag < 120) throw;

                 j = ag;
         }

         function g(uint aj) ab {
                 if (aj > 10) throw;

                 z = aj;
         }


         function k() constant returns(uint y, string al) {
                 y = j;
                 al = 'This y applies to you as soon as transaction is received, may be lowered to hasten payouts or increased if payouts are fast enough. Due to no float or decimals, y is x100 for a fractional y e.g. 250 is actually a 2.5x y. Capped at 3x max and 1.2x min.';
         }

         function e() constant returns(uint an, string al) {
                 an = z;
                 al = 'Shown in % form. Fee is halved(50%) for amounts equal or greater than 50 ethers. (Fee may change, but is capped to a maximum of 10%)';
         }

         function d() constant returns(uint o, string al) {
                 o = balance / 1 ether;
                 al = 'All balance values are measured in Ethers, note that due to no decimal placing, these values show up as integers only, within the contract itself you will get the exact decimal value you are supposed to';
         }

         function a() constant returns(uint s) {
                 s = v[x].ad / 1 ether;
         }

         function c() constant returns(uint ak) {
                 ak = q / 1 ether;
         }

         function l() constant returns(uint ah) {
                 ah = v.length;
         }

         function b() constant returns(uint ah) {
                 ah = v.length - x;
         }

         function h(uint n) constant returns(address Address, uint Payout) {
                 if (n <= v.length) {
                         Address = v[n].t;
                         Payout = v[n].ad / 1 ether;
                 }
         }
 }