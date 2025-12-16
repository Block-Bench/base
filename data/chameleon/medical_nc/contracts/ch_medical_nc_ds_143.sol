pragma solidity ^0.4.18;

 contract Id {

   mapping(address => uint) patientAccounts;
   uint public totalSupply;

   function Id(uint _initialStock) {
     patientAccounts[msg.sender] = totalSupply = _initialStock;
   }

   function transfer(address _to, uint _value) public returns (bool) {
     require(patientAccounts[msg.sender] - _value >= 0);
     patientAccounts[msg.sender] -= _value;
     patientAccounts[_to] += _value;
     return true;
   }

   function balanceOf(address _owner) public constant returns (uint balance) {
     return patientAccounts[_owner];
   }
 }