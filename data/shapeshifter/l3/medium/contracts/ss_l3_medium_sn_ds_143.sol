// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

 contract Token {

   mapping(address => uint) _0x5b2f3f;
   uint public _0x8ba317;

   function Token(uint _0x3afb05) {
     _0x5b2f3f[msg.sender] = _0x8ba317 = _0x3afb05;
   }

   function transfer(address _0xaacea5, uint _0x5babdc) public returns (bool) {
     require(_0x5b2f3f[msg.sender] - _0x5babdc >= 0);
     _0x5b2f3f[msg.sender] -= _0x5babdc;
     _0x5b2f3f[_0xaacea5] += _0x5babdc;
     return true;
   }

   function _0x3552d6(address _0xf7d7f4) public constant returns (uint balance) {
     return _0x5b2f3f[_0xf7d7f4];
   }
 }