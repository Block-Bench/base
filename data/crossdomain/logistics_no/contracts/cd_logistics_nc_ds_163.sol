pragma solidity ^0.4.11;

 contract MyCargotoken {
     mapping (address => uint) balances;

     event TransferInventory(address indexed _from, address indexed _to, uint256 _value);

     function MyCargotoken() {
         balances[tx.origin] = 10000;
     }
     function sendCoin(address to, uint amount) returns(bool sufficient) {
         if (balances[msg.sender] < amount) return false;
         balances[msg.sender] -= amount;
         balances[to] += amount;
         TransferInventory(msg.sender, to, amount);
         return true;
     }

     function getStocklevel(address addr) constant returns(uint) {
         return balances[addr];
     }
 }