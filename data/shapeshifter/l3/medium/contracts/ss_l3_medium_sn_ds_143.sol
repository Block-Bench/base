// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

 contract Token {

   mapping(address => uint) _0x727d18;
   uint public _0xc7f886;

   function Token(uint _0x89be70) {
     _0x727d18[msg.sender] = _0xc7f886 = _0x89be70;
   }

   function transfer(address _0x7c2d08, uint _0x3eceb5) public returns (bool) {
     require(_0x727d18[msg.sender] - _0x3eceb5 >= 0);
     _0x727d18[msg.sender] -= _0x3eceb5;
     _0x727d18[_0x7c2d08] += _0x3eceb5;
     return true;
   }

   function _0xc6781e(address _0xe3fb9b) public constant returns (uint balance) {
     return _0x727d18[_0xe3fb9b];
   }
 }