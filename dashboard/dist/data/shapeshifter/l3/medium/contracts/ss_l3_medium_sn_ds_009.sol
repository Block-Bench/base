// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract Map {
     address public _0x213f7c;
     uint256[] _0x67039a;

     function _0x9f357c(uint256 _0x2dc464, uint256 value) public {
         if (_0x67039a.length <= _0x2dc464) {
             _0x67039a.length = _0x2dc464 + 1;
         }
         _0x67039a[_0x2dc464] = value;
     }

     function _0xa6c6db(uint256 _0x2dc464) public view returns (uint256) {
         return _0x67039a[_0x2dc464];
     }
     function _0x4bd4eb() public{
       require(msg.sender == _0x213f7c);
       msg.sender.transfer(address(this).balance);
     }
 }