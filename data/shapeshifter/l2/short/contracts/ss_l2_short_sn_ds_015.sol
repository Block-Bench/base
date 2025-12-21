// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract Wallet {
     address e;

     mapping(address => uint256) c;

     function a() public {
         e = msg.sender;
     }

     function f() public payable {
         assert(c[msg.sender] + msg.value > c[msg.sender]);
         c[msg.sender] += msg.value;
     }

     function d(uint256 g) public {
         require(g <= c[msg.sender]);
         msg.sender.transfer(g);
         c[msg.sender] -= g;
     }

     // In an emergency the owner can migrate  allfunds to a different address.

     function b(address h) public {
         require(e == msg.sender);
         h.transfer(this.balance);
     }

 }
