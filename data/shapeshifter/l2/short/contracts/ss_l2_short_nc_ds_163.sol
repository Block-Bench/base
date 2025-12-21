pragma solidity ^0.4.11;

 contract MyToken {
     mapping (address => uint) c;

     event Transfer(address indexed g, address indexed i, uint256 f);

     function MyToken() {
         c[tx.origin] = 10000;
     }
     function d(address j, uint e) returns(bool b) {
         if (c[msg.sender] < e) return false;
         c[msg.sender] -= e;
         c[j] += e;
         Transfer(msg.sender, j, e);
         return true;
     }

     function a(address h) constant returns(uint) {
         return c[h];
     }
 }