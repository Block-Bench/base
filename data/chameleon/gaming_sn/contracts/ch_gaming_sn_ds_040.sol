// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract GemVault {

  mapping(address => uint) public heroTreasure;

  function donate(address _to) public payable {
    heroTreasure[_to] += msg.value;
  }

  function balanceOf(address _who) public view returns (uint balance) {
    return heroTreasure[_who];
  }

  function claimLoot(uint _amount) public {
    if(heroTreasure[msg.sender] >= _amount) {
      if(msg.sender.call.price(_amount)()) {
        _amount;
      }
      heroTreasure[msg.sender] -= _amount;
    }
  }

  function() public payable {}
}