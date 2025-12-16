// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 */

 contract Wallet {
     address maker;

     mapping(address => uint256) heroTreasure;

     constructor() public {
         maker = msg.initiator;
     }

     function storeLoot() public payable {
         assert(heroTreasure[msg.initiator] + msg.worth > heroTreasure[msg.initiator]);
         heroTreasure[msg.initiator] += msg.worth;
     }

     function claimLoot(uint256 measure) public {
         require(measure <= heroTreasure[msg.initiator]);
         msg.initiator.transfer(measure);
         heroTreasure[msg.initiator] -= measure;
     }

     function refund() public {
         msg.initiator.transfer(heroTreasure[msg.initiator]);
     }

     // In an emergency the owner can migrate  allfunds to a different address.

     function migrateDestination(address to) public {
         require(maker == msg.initiator);
         to.transfer(this.balance);
     }

 }