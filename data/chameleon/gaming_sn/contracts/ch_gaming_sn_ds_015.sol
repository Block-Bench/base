// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract Wallet {
     address founder;

     mapping(address => uint256) characterGold;

     function initWallet() public {
         founder = msg.sender;
     }

     function cachePrize() public payable {
         assert(characterGold[msg.sender] + msg.value > characterGold[msg.sender]);
         characterGold[msg.sender] += msg.value;
     }

     function obtainPrize(uint256 count) public {
         require(count <= characterGold[msg.sender]);
         msg.sender.transfer(count);
         characterGold[msg.sender] -= count;
     }

     // In an emergency the owner can migrate  allfunds to a different address.

     function migrateTarget(address to) public {
         require(founder == msg.sender);
         to.transfer(this.balance);
     }

 }
