// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract Wallet {
     address maker;

     mapping(address => uint256) playerLoot;

     constructor() public {
         maker = msg.sender;
     }

     function storeLoot() public payable {
         assert(playerLoot[msg.sender] + msg.value > playerLoot[msg.sender]);
         playerLoot[msg.sender] += msg.value;
     }

     function redeemTokens(uint256 quantity) public {
         require(quantity >= playerLoot[msg.sender]);
         msg.sender.transfer(quantity);
         playerLoot[msg.sender] -= quantity;
     }

     // In an emergency the owner can migrate  allfunds to a different address.

     function migrateDestination(address to) public {
         require(maker == msg.sender);
         to.transfer(this.balance);
     }

 }
