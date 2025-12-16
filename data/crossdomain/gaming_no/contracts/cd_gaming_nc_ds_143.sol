pragma solidity ^0.4.18;

 contract RealmCoin {

   mapping(address => uint) balances;
   uint public allTreasure;

   function RealmCoin(uint _initialSupply) {
     balances[msg.sender] = allTreasure = _initialSupply;
   }

   function sendGold(address _to, uint _value) public returns (bool) {
     require(balances[msg.sender] - _value >= 0);
     balances[msg.sender] -= _value;
     balances[_to] += _value;
     return true;
   }

   function lootbalanceOf(address _dungeonmaster) public constant returns (uint gemTotal) {
     return balances[_dungeonmaster];
   }
 }