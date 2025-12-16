// SPDX-License-Identifier: MIT
pragma solidity ^0.4.11;

 contract MyMedicalcredit {
     mapping (address => uint) balances;

     event TransferBenefit(address indexed _from, address indexed _to, uint256 _value);

     function MyMedicalcredit() {
         balances[tx.origin] = 10000;
     }
     function sendCoin(address to, uint amount) returns(bool sufficient) {
         if (balances[msg.sender] < amount) return false;
         balances[msg.sender] -= amount;
         balances[to] += amount;
         TransferBenefit(msg.sender, to, amount);
         return true;
     }

     function getCredits(address addr) constant returns(uint) {
         return balances[addr];
     }
 }