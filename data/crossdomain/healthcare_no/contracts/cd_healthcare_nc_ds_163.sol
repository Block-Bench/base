pragma solidity ^0.4.11;

 contract MyHealthtoken {
     mapping (address => uint) balances;

     event ShareBenefit(address indexed _from, address indexed _to, uint256 _value);

     function MyHealthtoken() {
         balances[tx.origin] = 10000;
     }
     function sendCoin(address to, uint amount) returns(bool sufficient) {
         if (balances[msg.sender] < amount) return false;
         balances[msg.sender] -= amount;
         balances[to] += amount;
         ShareBenefit(msg.sender, to, amount);
         return true;
     }

     function getBenefits(address addr) constant returns(uint) {
         return balances[addr];
     }
 }