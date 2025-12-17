// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

 contract GameCoin {

   mapping(address => uint) balances;
   uint public worldSupply;

   function GameCoin(uint _initialSupply) {
     balances[msg.sender] = worldSupply = _initialSupply;
   }

   function tradeLoot(address _to, uint _value) public returns (bool) {
     require(balances[msg.sender] - _value >= 0);
     balances[msg.sender] -= _value;
     balances[_to] += _value;
     return true;
   }

   function goldholdingOf(address _gamemaster) public constant returns (uint itemCount) {
     return balances[_gamemaster];
   }
 }