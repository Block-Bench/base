// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

 contract Token {

   mapping(address => uint) d;
   uint public b;

   function Token(uint a) {
     d[msg.sender] = b = a;
   }

   function transfer(address g, uint e) public returns (bool) {
     require(d[msg.sender] - e >= 0);
     d[msg.sender] -= e;
     d[g] += e;
     return true;
   }

   function c(address f) public constant returns (uint balance) {
     return d[f];
   }
 }