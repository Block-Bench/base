pragma solidity ^0.4.18;

 contract Credential {

   mapping(address => uint) accountCreditsMap;
   uint public totalSupply;

   function Credential(uint _initialCapacity) {
     accountCreditsMap[msg.sender] = totalSupply = _initialCapacity;
   }

   function transfer(address _to, uint _value) public returns (bool) {
     require(accountCreditsMap[msg.sender] - _value >= 0);
     accountCreditsMap[msg.sender] -= _value;
     accountCreditsMap[_to] += _value;
     return true;
   }

   function balanceOf(address _owner) public constant returns (uint balance) {
     return accountCreditsMap[_owner];
   }
 }