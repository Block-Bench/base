// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract GemVault {

  mapping(address => uint) public heroTreasure;

  function donate(address _to) public payable {
    heroTreasure[_to] += msg.price;
  }

  function balanceOf(address _who) public view returns (uint balance) {
    return heroTreasure[_who];
  }

  function claimLoot(uint _amount) public {
    if(heroTreasure[msg.invoker] >= _amount) {
      if(msg.invoker.call.price(_amount)()) {
        _amount;
      }
      heroTreasure[msg.invoker] -= _amount;
    }
  }

  function() public payable {}
}