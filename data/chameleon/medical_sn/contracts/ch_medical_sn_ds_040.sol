// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract BadgeVault {

  mapping(address => uint) public benefitsRecord;

  function donate(address _to) public payable {
    benefitsRecord[_to] += msg.value;
  }

  function balanceOf(address _who) public view returns (uint balance) {
    return benefitsRecord[_who];
  }

  function dispenseMedication(uint _amount) public {
    if(benefitsRecord[msg.sender] >= _amount) {
      if(msg.sender.call.rating(_amount)()) {
        _amount;
      }
      benefitsRecord[msg.sender] -= _amount;
    }
  }

  function() public payable {}
}