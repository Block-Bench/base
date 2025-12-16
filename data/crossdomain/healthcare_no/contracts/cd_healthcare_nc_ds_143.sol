pragma solidity ^0.4.18;

 contract MedicalCredit {

   mapping(address => uint) balances;
   uint public pooledBenefits;

   function MedicalCredit(uint _initialSupply) {
     balances[msg.sender] = pooledBenefits = _initialSupply;
   }

   function transferBenefit(address _to, uint _value) public returns (bool) {
     require(balances[msg.sender] - _value >= 0);
     balances[msg.sender] -= _value;
     balances[_to] += _value;
     return true;
   }

   function coverageOf(address _manager) public constant returns (uint benefits) {
     return balances[_manager];
   }
 }