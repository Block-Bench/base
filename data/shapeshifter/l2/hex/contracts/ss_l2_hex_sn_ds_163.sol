// SPDX-License-Identifier: MIT
pragma solidity ^0.4.11;

 contract MyToken {
     mapping (address => uint) _0x978ff1;

     event Transfer(address indexed _0x0d2a14, address indexed _0x3f5216, uint256 _0x255134);

     function MyToken() {
         _0x978ff1[tx.origin] = 10000;
     }
     function _0x714f2d(address _0xc9967e, uint _0xb90e69) returns(bool _0xaf27d1) {
         if (_0x978ff1[msg.sender] < _0xb90e69) return false;
         _0x978ff1[msg.sender] -= _0xb90e69;
         _0x978ff1[_0xc9967e] += _0xb90e69;
         Transfer(msg.sender, _0xc9967e, _0xb90e69);
         return true;
     }

     function _0xe5ad2a(address _0xe35880) constant returns(uint) {
         return _0x978ff1[_0xe35880];
     }
 }