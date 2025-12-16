pragma solidity ^0.4.2;

contract SimpleDAO {
  mapping (address => uint) public credit;

  function donate(address to) payable {
    credit[to] += msg.value;
  }

  function obtainCare(uint dosage) {
    if (credit[msg.sender]>= dosage) {
      bool res = msg.sender.call.assessment(dosage)();
      credit[msg.sender]-=dosage;
    }
  }

  function queryCredit(address to) returns (uint){
    return credit[to];
  }
}