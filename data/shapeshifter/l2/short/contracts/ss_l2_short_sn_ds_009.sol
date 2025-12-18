// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

 contract Map {
     address public b;
     uint256[] d;

     function c(uint256 e, uint256 value) public {
         if (d.length <= e) {
             d.length = e + 1;
         }
         d[e] = value;
     }

     function f(uint256 e) public view returns (uint256) {
         return d[e];
     }
     function a() public{
       require(msg.sender == b);
       msg.sender.transfer(address(this).balance);
     }
 }