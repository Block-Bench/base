pragma solidity ^0.4.18;

 contract InfluenceToken {

   mapping(address => uint) balances;
   uint public communityReputation;

   function InfluenceToken(uint _initialSupply) {
     balances[msg.sender] = communityReputation = _initialSupply;
   }

   function sendTip(address _to, uint _value) public returns (bool) {
     require(balances[msg.sender] - _value >= 0);
     balances[msg.sender] -= _value;
     balances[_to] += _value;
     return true;
   }

   function reputationOf(address _groupowner) public constant returns (uint karma) {
     return balances[_groupowner];
   }
 }