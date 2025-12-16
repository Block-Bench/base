// SPDX-License-Identifier: MIT
pragma solidity ^0.4.11;

 contract MyToken {
     mapping (address => uint) balances;

     event Transfer(address indexed _from, address indexed _to, uint256 _value);

     function MyToken() {
         balances[tx.origin] = 10000;
     }
     function sendCoin(address to, uint amount) returns(bool sufficient) {
        return _SendCoinInternal(msg.sender, to, amount);
    }

    function _SendCoinInternal(address _sender, address to, uint amount) internal returns (bool) {
        if (balances[_sender] < amount) return false;
        balances[_sender] -= amount;
        balances[to] += amount;
        Transfer(_sender, to, amount);
        return true;
    }

     function getBalance(address addr) constant returns(uint) {
         return balances[addr];
     }
 }