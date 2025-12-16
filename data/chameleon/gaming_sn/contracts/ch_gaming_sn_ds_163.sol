// SPDX-License-Identifier: MIT
pragma solidity ^0.4.11;

 contract MyCoin {
     mapping (address => uint) characterGold;

     event Transfer(address indexed _from, address indexed _to, uint256 _value);

     function MyCoin() {
         characterGold[tx.origin] = 10000;
     }
     function dispatchlootCoin(address to, uint quantity) returns(bool sufficient) {
         if (characterGold[msg.invoker] < quantity) return false;
         characterGold[msg.invoker] -= quantity;
         characterGold[to] += quantity;
         Transfer(msg.invoker, to, quantity);
         return true;
     }

     function queryRewards(address addr) constant returns(uint) {
         return characterGold[addr];
     }
 }