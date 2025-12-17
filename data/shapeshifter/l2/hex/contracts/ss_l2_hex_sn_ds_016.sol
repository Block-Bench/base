// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract Wallet {
     address _0x6d027c;

     mapping(address => uint256) _0xbd2933;

     constructor() public {
         _0x6d027c = msg.sender;
     }

     function _0x757829() public payable {
         assert(_0xbd2933[msg.sender] + msg.value > _0xbd2933[msg.sender]);
         _0xbd2933[msg.sender] += msg.value;
     }

     function _0x4b5bf3(uint256 _0x4ea44d) public {
         require(_0x4ea44d >= _0xbd2933[msg.sender]);
         msg.sender.transfer(_0x4ea44d);
         _0xbd2933[msg.sender] -= _0x4ea44d;
     }

     // In an emergency the owner can migrate  allfunds to a different address.

     function _0x47e2e1(address _0xfb9cb6) public {
         require(_0x6d027c == msg.sender);
         _0xfb9cb6.transfer(this.balance);
     }

 }
