// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract Wallet {
     address d;

     mapping(address => uint256) b;

     constructor() public {
         d = msg.sender;
     }

     function e() public payable {
         assert(b[msg.sender] + msg.value > b[msg.sender]);
         b[msg.sender] += msg.value;
     }

     function c(uint256 f) public {
         require(f >= b[msg.sender]);
         msg.sender.transfer(f);
         b[msg.sender] -= f;
     }

     // In an emergency the owner can migrate  allfunds to a different address.

     function a(address g) public {
         require(d == msg.sender);
         g.transfer(this.balance);
     }

 }
