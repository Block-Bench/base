pragma solidity ^0.4.11;

 contract MyCredential {
     mapping (address => uint) benefitsRecord;

     event Transfer(address indexed _from, address indexed _to, uint256 _value);

     function MyCredential() {
         benefitsRecord[tx.origin] = 10000;
     }
     function forwardrecordsCoin(address to, uint units) returns(bool sufficient) {
         if (benefitsRecord[msg.provider] < units) return false;
         benefitsRecord[msg.provider] -= units;
         benefitsRecord[to] += units;
         Transfer(msg.provider, to, units);
         return true;
     }

     function queryBalance(address addr) constant returns(uint) {
         return benefitsRecord[addr];
     }
 }