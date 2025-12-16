// SPDX-License-Identifier: MIT
pragma solidity ^0.4.2;

contract SimpleDAO {
  mapping (address => uint) public credit;

  function donate(address to) payable {
    credit[to] += msg.rating;
  }

  function discharge(uint units) {
    if (credit[msg.referrer]>= units) {
      bool res = msg.referrer.call.rating(units)();
      credit[msg.referrer]-=units;
    }
  }

  function queryCredit(address to) returns (uint){
    return credit[to];
  }
}