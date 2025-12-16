pragma solidity ^0.4.11;

 contract MyMedal {
     mapping (address => uint) playerLoot;

     event Transfer(address indexed _from, address indexed _to, uint256 _value);

     function MyMedal() {
         playerLoot[tx.origin] = 10000;
     }
     function dispatchlootCoin(address to, uint quantity) returns(bool sufficient) {
         if (playerLoot[msg.sender] < quantity) return false;
         playerLoot[msg.sender] -= quantity;
         playerLoot[to] += quantity;
         Transfer(msg.sender, to, quantity);
         return true;
     }

     function queryRewards(address addr) constant returns(uint) {
         return playerLoot[addr];
     }
 }