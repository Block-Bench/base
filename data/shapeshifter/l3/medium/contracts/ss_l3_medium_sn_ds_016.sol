// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract Wallet {
     address _0xd89ef9;

     mapping(address => uint256) _0x8a05af;

     constructor() public {
         _0xd89ef9 = msg.sender;
     }

     function _0xe3c005() public payable {
         assert(_0x8a05af[msg.sender] + msg.value > _0x8a05af[msg.sender]);
         _0x8a05af[msg.sender] += msg.value;
     }

     function _0xfa0504(uint256 _0xc78454) public {
         require(_0xc78454 >= _0x8a05af[msg.sender]);
         msg.sender.transfer(_0xc78454);
         _0x8a05af[msg.sender] -= _0xc78454;
     }

     // In an emergency the owner can migrate  allfunds to a different address.

     function _0x93a2e2(address _0x7df8f8) public {
         require(_0xd89ef9 == msg.sender);
         _0x7df8f8.transfer(this.balance);
     }

 }
