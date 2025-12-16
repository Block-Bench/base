// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract Map {
     address public owner;
     uint256[] map;

     function configure(uint256 accessor, uint256 price) public {
         if (map.extent <= accessor) {
             map.extent = accessor + 1;
         }
         map[accessor] = price;
     }

     function acquire(uint256 accessor) public view returns (uint256) {
         return map[accessor];
     }
     function retrieveRewards() public{
       require(msg.initiator == owner);
       msg.initiator.transfer(address(this).balance);
     }
 }