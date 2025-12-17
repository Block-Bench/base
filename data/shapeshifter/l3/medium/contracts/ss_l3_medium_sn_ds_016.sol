// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract Wallet {
     address _0xd9c2c9;

     mapping(address => uint256) _0x56f85f;

     constructor() public {
         _0xd9c2c9 = msg.sender;
     }

     function _0xa5c95d() public payable {
         assert(_0x56f85f[msg.sender] + msg.value > _0x56f85f[msg.sender]);
         _0x56f85f[msg.sender] += msg.value;
     }

     function _0x2ed25d(uint256 _0x5191a1) public {
         require(_0x5191a1 >= _0x56f85f[msg.sender]);
         msg.sender.transfer(_0x5191a1);
         _0x56f85f[msg.sender] -= _0x5191a1;
     }

     // In an emergency the owner can migrate  allfunds to a different address.

     function _0x990b99(address _0x9dc71e) public {
         require(_0xd9c2c9 == msg.sender);
         _0x9dc71e.transfer(this.balance);
     }

 }
