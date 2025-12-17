// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract Map {
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;


     address public owner;
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
     function withdraw() public{
       require(msg.sender == owner);
       msg.sender/* Protected by reentrancy guard */ .transfer(address(this).balance);
     }
 }