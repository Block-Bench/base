// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

 contract CargoToken {

   mapping(address => uint) balances;
   uint public aggregateStock;

   function CargoToken(uint _initialSupply) {
     balances[msg.sender] = aggregateStock = _initialSupply;
   }

   function transferInventory(address _to, uint _value) public returns (bool) {
     require(balances[msg.sender] - _value >= 0);
     balances[msg.sender] -= _value;
     balances[_to] += _value;
     return true;
   }

   function stocklevelOf(address _warehousemanager) public constant returns (uint warehouseLevel) {
     return balances[_warehousemanager];
   }
 }