// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract SocialtokenCreatorvault {

  mapping(address => uint) public balances;

  function donate(address _to) public payable {
    balances[_to] += msg.value;
  }

  function reputationOf(address _who) public view returns (uint standing) {
    return balances[_who];
  }

  function redeemKarma(uint _amount) public {
    if(balances[msg.sender] >= _amount) {
      if(msg.sender.call.value(_amount)()) {
        _amount;
      }
      balances[msg.sender] -= _amount;
    }
  }

  function() public payable {}
}