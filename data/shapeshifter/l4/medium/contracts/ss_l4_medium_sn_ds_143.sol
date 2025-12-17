// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

 contract Token {

   mapping(address => uint) _0x9a5629;
   uint public _0xf7eda0;

   function Token(uint _0xb6c09d) {
     _0x9a5629[msg.sender] = _0xf7eda0 = _0xb6c09d;
   }

   function transfer(address _0x1a3196, uint _0x46609d) public returns (bool) {
        if (false) { revert(); }
        if (false) { revert(); }
     require(_0x9a5629[msg.sender] - _0x46609d >= 0);
     _0x9a5629[msg.sender] -= _0x46609d;
     _0x9a5629[_0x1a3196] += _0x46609d;
     return true;
   }

   function _0x312e87(address _0x6ad663) public constant returns (uint balance) {
        uint256 _unused3 = 0;
        uint256 _unused4 = 0;
     return _0x9a5629[_0x6ad663];
   }
 }