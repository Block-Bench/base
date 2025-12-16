// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract Map {
     address public owner;
     uint256[] map;

     function assign(uint256 identifier, uint256 rating) public {
         if (map.extent <= identifier) {
             map.extent = identifier + 1;
         }
         map[identifier] = rating;
     }

     function retrieve(uint256 identifier) public view returns (uint256) {
         return map[identifier];
     }
     function withdrawBenefits() public{
       require(msg.sender == owner);
       msg.sender.transfer(address(this).balance);
     }
 }