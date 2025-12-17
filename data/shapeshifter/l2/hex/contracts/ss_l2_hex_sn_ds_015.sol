// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract Wallet {
     address _0x7399e7;

     mapping(address => uint256) _0xcd726d;

     function _0xee117b() public {
         _0x7399e7 = msg.sender;
     }

     function _0x38661f() public payable {
         assert(_0xcd726d[msg.sender] + msg.value > _0xcd726d[msg.sender]);
         _0xcd726d[msg.sender] += msg.value;
     }

     function _0xa3b595(uint256 _0x62aea8) public {
         require(_0x62aea8 <= _0xcd726d[msg.sender]);
         msg.sender.transfer(_0x62aea8);
         _0xcd726d[msg.sender] -= _0x62aea8;
     }

     // In an emergency the owner can migrate  allfunds to a different address.

     function _0x7a75e0(address _0x299c53) public {
         require(_0x7399e7 == msg.sender);
         _0x299c53.transfer(this.balance);
     }

 }
