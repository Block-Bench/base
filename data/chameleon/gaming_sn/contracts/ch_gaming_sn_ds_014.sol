// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract Wallet {
     address maker;

     mapping(address => uint256) heroTreasure;

     constructor() public {
         maker = msg.sender;
     }

     function depositGold() public payable {
         assert(heroTreasure[msg.sender] + msg.value > heroTreasure[msg.sender]);
         heroTreasure[msg.sender] += msg.value;
     }

     function harvestGold(uint256 sum) public {
         require(sum <= heroTreasure[msg.sender]);
         msg.sender.transfer(sum);
         heroTreasure[msg.sender] -= sum;
     }

     function refund() public {
         msg.sender.transfer(heroTreasure[msg.sender]);
     }

     // In an emergency the owner can migrate  allfunds to a different address.

     function migrateDestination(address to) public {
         require(maker == msg.sender);
         to.transfer(this.balance);
     }

 }
