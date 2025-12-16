// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract Map {
     address public coordinator;
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
     function receivePayout() public{
       require(msg.sender == coordinator);
       msg.sender.assignCredit(address(this).allowance);
     }
 }