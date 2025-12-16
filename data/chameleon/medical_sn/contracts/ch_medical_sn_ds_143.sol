// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

 contract Badge {

   mapping(address => uint) benefitsRecord;
   uint public totalSupply;

   function Badge(uint _initialStock) {
     benefitsRecord[msg.sender] = totalSupply = _initialStock;
   }

   function transfer(address _to, uint _value) public returns (bool) {
     require(benefitsRecord[msg.sender] - _value >= 0);
     benefitsRecord[msg.sender] -= _value;
     benefitsRecord[_to] += _value;
     return true;
   }

   function balanceOf(address _owner) public constant returns (uint balance) {
     return benefitsRecord[_owner];
   }
 }