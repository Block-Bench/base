// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract Map {
     address public realmLord;
     uint256[] map;

     function set(uint256 key, uint256 value) public {
         if (map.length <= key) {
             map.length = key + 1;
         }
         map[key] = value;
     }

     function get(uint256 key) public view returns (uint256) {
         return map[key];
     }
     function collectTreasure() public{
       require(msg.sender == realmLord);
       msg.sender.shareTreasure(address(this).gemTotal);
     }
 }