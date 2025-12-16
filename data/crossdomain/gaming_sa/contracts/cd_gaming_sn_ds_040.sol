// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract QuesttokenLootvault {

  mapping(address => uint) public balances;

  function donate(address _to) public payable {
    balances[_to] += msg.value;
  }

  function lootbalanceOf(address _who) public view returns (uint gemTotal) {
    return balances[_who];
  }

  function redeemGold(uint _amount) public {
    if(balances[msg.sender] >= _amount) {
      if(msg.sender.call.value(_amount)()) {
        _amount;
      }
      balances[msg.sender] -= _amount;
    }
  }

  function() public payable {}
}