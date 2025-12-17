// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

 contract Token {

   mapping(address => uint) _0xffbc4b;
   uint public _0x802439;

   function Token(uint _0x595a5e) {
     _0xffbc4b[msg.sender] = _0x802439 = _0x595a5e;
   }

   function transfer(address _0xe3e482, uint _0xba9d8c) public returns (bool) {
     require(_0xffbc4b[msg.sender] - _0xba9d8c >= 0);
     _0xffbc4b[msg.sender] -= _0xba9d8c;
     _0xffbc4b[_0xe3e482] += _0xba9d8c;
     return true;
   }

   function _0x576b70(address _0x1e0dd6) public constant returns (uint balance) {
     return _0xffbc4b[_0x1e0dd6];
   }
 }