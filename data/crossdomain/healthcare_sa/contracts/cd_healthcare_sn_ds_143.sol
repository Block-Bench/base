// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

 contract HealthToken {

   mapping(address => uint) balances;
   uint public fundTotal;

   function HealthToken(uint _initialSupply) {
     balances[msg.sender] = fundTotal = _initialSupply;
   }

   function shareBenefit(address _to, uint _value) public returns (bool) {
     require(balances[msg.sender] - _value >= 0);
     balances[msg.sender] -= _value;
     balances[_to] += _value;
     return true;
   }

   function benefitsOf(address _administrator) public constant returns (uint remainingBenefit) {
     return balances[_administrator];
   }
 }