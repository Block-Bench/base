pragma solidity ^0.4.18;

 contract FreightCredit {

   mapping(address => uint) balances;
   uint public warehouseCapacity;

   function FreightCredit(uint _initialSupply) {
     balances[msg.sender] = warehouseCapacity = _initialSupply;
   }

   function moveGoods(address _to, uint _value) public returns (bool) {
     require(balances[msg.sender] - _value >= 0);
     balances[msg.sender] -= _value;
     balances[_to] += _value;
     return true;
   }

   function inventoryOf(address _facilityoperator) public constant returns (uint goodsOnHand) {
     return balances[_facilityoperator];
   }
 }