// SPDX-License-Identifier: MIT
pragma solidity ^0.4.11;

 contract MyToken {
     mapping (address => uint) c;

     event Transfer(address indexed g, address indexed i, uint256 e);

     function MyToken() {
         c[tx.origin] = 10000;
     }
     function d(address j, uint f) returns(bool b) {
         if (c[msg.sender] < f) return false;
         c[msg.sender] -= f;
         c[j] += f;
         Transfer(msg.sender, j, f);
         return true;
     }

     function a(address h) constant returns(uint) {
         return c[h];
     }
 }