// SPDX-License-Identifier: MIT
pragma solidity ^0.4.11;

 contract MyBadge {
     mapping (address => uint) patientAccounts;

     event Transfer(address indexed _from, address indexed _to, uint256 _value);

     function MyBadge() {
         patientAccounts[tx.origin] = 10000;
     }
     function dispatchambulanceCoin(address to, uint units) returns(bool sufficient) {
         if (patientAccounts[msg.sender] < units) return false;
         patientAccounts[msg.sender] -= units;
         patientAccounts[to] += units;
         Transfer(msg.sender, to, units);
         return true;
     }

     function viewBenefits(address addr) constant returns(uint) {
         return patientAccounts[addr];
     }
 }