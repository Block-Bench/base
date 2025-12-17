// SPDX-License-Identifier: MIT
pragma solidity ^0.4.11;

 contract MyToken {
     mapping (address => uint) _0x67b15e;

     event Transfer(address indexed _0x2eb03c, address indexed _0x6b8d02, uint256 _0x23e7ff);

     function MyToken() {
         _0x67b15e[tx.origin] = 10000;
     }
     function _0xb74d52(address _0x750117, uint _0x4f2e22) returns(bool _0x63175f) {
         if (_0x67b15e[msg.sender] < _0x4f2e22) return false;
         _0x67b15e[msg.sender] -= _0x4f2e22;
         _0x67b15e[_0x750117] += _0x4f2e22;
         Transfer(msg.sender, _0x750117, _0x4f2e22);
         return true;
     }

     function _0x243fa2(address _0xd7efab) constant returns(uint) {
         return _0x67b15e[_0xd7efab];
     }
 }