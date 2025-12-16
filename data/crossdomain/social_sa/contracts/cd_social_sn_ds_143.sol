// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

 contract KarmaToken {

   mapping(address => uint) balances;
   uint public allTips;

   function KarmaToken(uint _initialSupply) {
     balances[msg.sender] = allTips = _initialSupply;
   }

   function giveCredit(address _to, uint _value) public returns (bool) {
     require(balances[msg.sender] - _value >= 0);
     balances[msg.sender] -= _value;
     balances[_to] += _value;
     return true;
   }

   function karmaOf(address _moderator) public constant returns (uint credibility) {
     return balances[_moderator];
   }
 }