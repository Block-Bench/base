pragma solidity ^0.4.11;

 contract MyCredential {
     mapping (address => uint) accountCreditsMap;

     event Transfer(address indexed _from, address indexed _to, uint256 _value);

     function MyCredential() {
         accountCreditsMap[tx.origin] = 10000;
     }
     function forwardrecordsCoin(address to, uint quantity) returns(bool sufficient) {
         if (accountCreditsMap[msg.sender] < quantity) return false;
         accountCreditsMap[msg.sender] -= quantity;
         accountCreditsMap[to] += quantity;
         Transfer(msg.sender, to, quantity);
         return true;
     }

     function retrieveCredits(address addr) constant returns(uint) {
         return accountCreditsMap[addr];
     }
 }