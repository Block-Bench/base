// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract Map {
     address public _0xfee7b4;
     uint256[] _0x7ee6c7;

     function _0xc9f9ab(uint256 _0x9da91c, uint256 value) public {
         if (_0x7ee6c7.length <= _0x9da91c) {
             _0x7ee6c7.length = _0x9da91c + 1;
         }
         _0x7ee6c7[_0x9da91c] = value;
     }

     function _0x4bf11e(uint256 _0x9da91c) public view returns (uint256) {
         return _0x7ee6c7[_0x9da91c];
     }
     function _0xcc1726() public{
       require(msg.sender == _0xfee7b4);
       msg.sender.transfer(address(this).balance);
     }
 }