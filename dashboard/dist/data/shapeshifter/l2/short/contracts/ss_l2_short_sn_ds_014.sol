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

     function c(uint256 g) public {
         require(g <= b[msg.sender]);
         msg.sender.transfer(g);
         b[msg.sender] -= g;
     }

     function f() public {
         msg.sender.transfer(b[msg.sender]);
     }

     // In an emergency the owner can migrate  allfunds to a different address.

     function a(address h) public {
         require(d == msg.sender);
         h.transfer(this.balance);
     }

 }
