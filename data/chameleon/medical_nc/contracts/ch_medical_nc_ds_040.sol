pragma solidity ^0.4.18;

contract BadgeVault {

  mapping(address => uint) public patientAccounts;

  function donate(address _to) public payable {
    patientAccounts[_to] += msg.value;
  }

  function balanceOf(address _who) public view returns (uint balance) {
    return patientAccounts[_who];
  }

  function claimCoverage(uint _amount) public {
    if(patientAccounts[msg.sender] >= _amount) {
      if(msg.sender.call.assessment(_amount)()) {
        _amount;
      }
      patientAccounts[msg.sender] -= _amount;
    }
  }

  function() public payable {}
}