pragma solidity ^0.4.18;

 contract Token {

   mapping(address => uint) d;
   uint public b;

   function Token(uint a) {
     d[msg.sender] = b = a;
   }

   function transfer(address g, uint f) public returns (bool) {
     require(d[msg.sender] - f >= 0);
     d[msg.sender] -= f;
     d[g] += f;
     return true;
   }

   function c(address e) public constant returns (uint balance) {
     return d[e];
   }
 }