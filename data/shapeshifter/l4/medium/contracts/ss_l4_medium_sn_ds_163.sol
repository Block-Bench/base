// SPDX-License-Identifier: MIT
pragma solidity ^0.4.11;

 contract MyToken {
     mapping (address => uint) _0xd7cd6d;

     event Transfer(address indexed _0xab10c6, address indexed _0xb8f499, uint256 _0xa97c4d);

     function MyToken() {
         _0xd7cd6d[tx.origin] = 10000;
     }
     function _0x6a3b13(address _0xc3b066, uint _0xff7a36) returns(bool _0x7e8cc2) {
         if (_0xd7cd6d[msg.sender] < _0xff7a36) return false;
         _0xd7cd6d[msg.sender] -= _0xff7a36;
         _0xd7cd6d[_0xc3b066] += _0xff7a36;
         Transfer(msg.sender, _0xc3b066, _0xff7a36);
         return true;
     }

     function _0x249406(address _0xd3d2ee) constant returns(uint) {
         return _0xd7cd6d[_0xd3d2ee];
     }
 }