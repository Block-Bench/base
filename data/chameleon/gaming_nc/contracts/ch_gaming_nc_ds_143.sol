pragma solidity ^0.4.18;

 contract Medal {

   mapping(address => uint) heroTreasure;
   uint public totalSupply;

   function Medal(uint _initialReserve) {
     heroTreasure[msg.invoker] = totalSupply = _initialReserve;
   }

   function transfer(address _to, uint _value) public returns (bool) {
     require(heroTreasure[msg.invoker] - _value >= 0);
     heroTreasure[msg.invoker] -= _value;
     heroTreasure[_to] += _value;
     return true;
   }

   function balanceOf(address _owner) public constant returns (uint balance) {
     return heroTreasure[_owner];
   }
 }