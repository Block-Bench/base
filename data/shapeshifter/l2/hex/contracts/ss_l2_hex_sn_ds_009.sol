// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract Map {
     address public _0xabeb91;
     uint256[] _0xc48a44;

     function _0xa6e261(uint256 _0x30b724, uint256 value) public {
         if (_0xc48a44.length <= _0x30b724) {
             _0xc48a44.length = _0x30b724 + 1;
         }
         _0xc48a44[_0x30b724] = value;
     }

     function _0x974d81(uint256 _0x30b724) public view returns (uint256) {
         return _0xc48a44[_0x30b724];
     }
     function _0x3c6fd0() public{
       require(msg.sender == _0xabeb91);
       msg.sender.transfer(address(this).balance);
     }
 }