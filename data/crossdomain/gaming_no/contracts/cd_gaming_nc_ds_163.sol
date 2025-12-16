pragma solidity ^0.4.11;

 contract MyGamecoin {
     mapping (address => uint) balances;

     event TradeLoot(address indexed _from, address indexed _to, uint256 _value);

     function MyGamecoin() {
         balances[tx.origin] = 10000;
     }
     function sendCoin(address to, uint amount) returns(bool sufficient) {
         if (balances[msg.sender] < amount) return false;
         balances[msg.sender] -= amount;
         balances[to] += amount;
         TradeLoot(msg.sender, to, amount);
         return true;
     }

     function getGoldholding(address addr) constant returns(uint) {
         return balances[addr];
     }
 }