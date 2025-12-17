// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract Wallet {
     address _0xc6e376;

     mapping(address => uint256) _0xd813b1;

     constructor() public {
         _0xc6e376 = msg.sender;
     }

     function _0xbdc6a2() public payable {
         assert(_0xd813b1[msg.sender] + msg.value > _0xd813b1[msg.sender]);
         _0xd813b1[msg.sender] += msg.value;
     }

     function _0x5c0325(uint256 _0x2a8be8) public {
         require(_0x2a8be8 <= _0xd813b1[msg.sender]);
         msg.sender.transfer(_0x2a8be8);
         _0xd813b1[msg.sender] -= _0x2a8be8;
     }

     function _0x3b8bfe() public {
         msg.sender.transfer(_0xd813b1[msg.sender]);
     }

     // In an emergency the owner can migrate  allfunds to a different address.

     function _0xf522a0(address _0x80c290) public {
         require(_0xc6e376 == msg.sender);
         _0x80c290.transfer(this.balance);
     }

 }
