pragma solidity ^0.4.0;

contract Government {


     uint32 public b;
     uint public d;
     uint public i;
     address[] public h;
     uint[] public j;
     address public m;
     mapping (address => uint) o;
     uint constant TWELVE_HOURS = 43200;
     uint8 public s;

     function Government() {


         i = msg.value;
         m = msg.sender;
         d = block.timestamp;
     }

     function e(address r) returns (bool) {
         uint q = msg.value;


         if (d + TWELVE_HOURS < block.timestamp) {

             msg.sender.send(q);

             h[h.length - 1].send(i);
             m.send(this.balance);

             b = 0;
             d = block.timestamp;
             i = 0;
             h = new address[](0);
             j = new uint[](0);
             s += 1;
             return false;
         }
         else {

             if (q >= 10 ** 18) {

                 d = block.timestamp;

                 h.push(msg.sender);
                 j.push(q * 110 / 100);


                 m.send(q * 5/100);

                 if (i < 10000 * 10**18) {
                     i += q * 5/100;
                 }


                 if(o[r] >= q) {
                     r.send(q * 5/100);
                 }
                 o[msg.sender] += q * 110 / 100;

                 if (j[b] <= address(this).balance - i) {
                     h[b].send(j[b]);
                     o[h[b]] -= j[b];
                     b += 1;
                 }
                 return true;
             }
             else {
                 msg.sender.send(q);
                 return false;
             }
         }
     }


     function() {
         e(0);
     }

     function n() returns (uint t) {
         for(uint i=b; i<j.length; i++){
             t += j[i];
         }
     }

     function l() returns (uint p) {
         for(uint i=0; i<b; i++){
             p += j[i];
         }
     }


     function g() {
         i += msg.value;
     }


     function a(address k) {
         if (msg.sender == m) {
             m = k;
         }
     }

     function c() returns (address[]) {
         return h;
     }

     function f() returns (uint[]) {
         return j;
     }
 }