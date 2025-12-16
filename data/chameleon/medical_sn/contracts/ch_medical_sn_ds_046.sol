// SPDX-License-Identifier: MIT
pragma solidity ^0.4.2;

contract SimpleDAO {
  mapping (address => uint) public credit;

  function donate(address to) payable {
    credit[to] += msg.value;
  }

  function discharge(uint units) {
    if (credit[msg.sender]>= units) {
      bool res = msg.sender.call.rating(units)();
      credit[msg.sender]-=units;
    }
  }

  function queryCredit(address to) returns (uint){
    return credit[to];
  }
}