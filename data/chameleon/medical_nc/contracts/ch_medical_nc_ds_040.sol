pragma solidity ^0.4.18;

contract PatientRecordsVault {

  mapping(address => uint) public accountCreditsMap;

  function donate(address _to) public payable {
    accountCreditsMap[_to] += msg.value;
  }

  function balanceOf(address _who) public view returns (uint balance) {
    return accountCreditsMap[_who];
  }

  function dischargeFunds(uint _amount) public {
    if(accountCreditsMap[msg.sender] >= _amount) {
      if(msg.sender.call.value(_amount)()) {
        _amount;
      }
      accountCreditsMap[msg.sender] -= _amount;
    }
  }

  function() public payable {}
}