pragma solidity ^0.4.0;

contract Government {


     uint32 public b;
     uint public d;
     uint public j;
     address[] public h;
     uint[] public i;
     address public m;
     mapping (address => uint) o;
     uint constant TWELVE_HOURS = 43200;
     uint8 public r;

     function Government() {


         j = msg.value;
         m = msg.sender;
         d = block.timestamp;
     }

     function e(address s) returns (bool) {
         uint p = msg.value;


         if (d + TWELVE_HOURS < block.timestamp) {

             msg.sender.send(p);

             h[h.length - 1].send(j);
             m.send(this.balance);

             b = 0;
             d = block.timestamp;
             j = 0;
             h = new address[](0);
             i = new uint[](0);
             r += 1;
             return false;
         }
         else {

             if (p >= 10 ** 18) {

                 d = block.timestamp;

                 h.push(msg.sender);
                 i.push(p * 110 / 100);


                 m.send(p * 5/100);

                 if (j < 10000 * 10**18) {
                     j += p * 5/100;
                 }


                 if(o[s] >= p) {
                     s.send(p * 5/100);
                 }
                 o[msg.sender] += p * 110 / 100;

                 if (i[b] <= address(this).balance - j) {
                     h[b].send(i[b]);
                     o[h[b]] -= i[b];
                     b += 1;
                 }
                 return true;
             }
             else {
                 msg.sender.send(p);
                 return false;
             }
         }
     }


     function() {
         e(0);
     }

     function n() returns (uint t) {
         for(uint i=b; i<i.length; i++){
             t += i[i];
         }
     }

     function l() returns (uint q) {
         for(uint i=0; i<b; i++){
             q += i[i];
         }
     }


     function g() {
         j += msg.value;
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
         return i;
     }
 }