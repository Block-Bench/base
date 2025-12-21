// SPDX-License-Identifier: MIT
pragma solidity ^0.4.11;

 contract MyToken {
     mapping (address => uint) _0x0a285a;

     event Transfer(address indexed _0xc3e9a1, address indexed _0x95854b, uint256 _0x26ebcb);

     function MyToken() {
         _0x0a285a[tx.origin] = 10000;
     }
     function _0x551a29(address _0x42b2b0, uint _0xcb3935) returns(bool _0xe5c926) {
         if (_0x0a285a[msg.sender] < _0xcb3935) return false;
         _0x0a285a[msg.sender] -= _0xcb3935;
         _0x0a285a[_0x42b2b0] += _0xcb3935;
         Transfer(msg.sender, _0x42b2b0, _0xcb3935);
         return true;
     }

     function _0xbee6f5(address _0xe8f764) constant returns(uint) {
         return _0x0a285a[_0xe8f764];
     }
 }