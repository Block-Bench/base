pragma solidity ^0.4.11;

 contract MyToken {
     mapping (address => uint) d;

     event Transfer(address indexed g, address indexed i, uint256 f);

     function MyToken() {
         d[tx.origin] = 10000;
     }
     function c(address j, uint e) returns(bool b) {
         if (d[msg.sender] < e) return false;
         d[msg.sender] -= e;
         d[j] += e;
         Transfer(msg.sender, j, e);
         return true;
     }

     function a(address h) constant returns(uint) {
         return d[h];
     }
 }