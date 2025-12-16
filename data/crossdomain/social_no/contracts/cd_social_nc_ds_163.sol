pragma solidity ^0.4.11;

 contract MyKarmatoken {
     mapping (address => uint) balances;

     event GiveCredit(address indexed _from, address indexed _to, uint256 _value);

     function MyKarmatoken() {
         balances[tx.origin] = 10000;
     }
     function sendCoin(address to, uint amount) returns(bool sufficient) {
         if (balances[msg.sender] < amount) return false;
         balances[msg.sender] -= amount;
         balances[to] += amount;
         GiveCredit(msg.sender, to, amount);
         return true;
     }

     function getKarma(address addr) constant returns(uint) {
         return balances[addr];
     }
 }