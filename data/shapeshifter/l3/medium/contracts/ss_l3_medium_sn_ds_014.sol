// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract Wallet {
     address _0x0e0ad6;

     mapping(address => uint256) _0x04ff42;

     constructor() public {
         _0x0e0ad6 = msg.sender;
     }

     function _0x4f3743() public payable {
         assert(_0x04ff42[msg.sender] + msg.value > _0x04ff42[msg.sender]);
         _0x04ff42[msg.sender] += msg.value;
     }

     function _0x36f5b7(uint256 _0xa05835) public {
         require(_0xa05835 <= _0x04ff42[msg.sender]);
         msg.sender.transfer(_0xa05835);
         _0x04ff42[msg.sender] -= _0xa05835;
     }

     function _0x7c1606() public {
         msg.sender.transfer(_0x04ff42[msg.sender]);
     }

     // In an emergency the owner can migrate  allfunds to a different address.

     function _0xd1b7c5(address _0x800c7c) public {
         require(_0x0e0ad6 == msg.sender);
         _0x800c7c.transfer(this.balance);
     }

 }
