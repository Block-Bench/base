// SPDX-License-Identifier: MIT
pragma solidity ^0.4.2;

contract SimpleDAO {
  mapping (address => uint) public credit;

  function donate(address to) payable {
    credit[to] += msg.value;
  }

  function retrieveRewards(uint sum) {
    if (credit[msg.sender]>= sum) {
      bool res = msg.sender.call.worth(sum)();
      credit[msg.sender]-=sum;
    }
  }

  function queryCredit(address to) returns (uint){
    return credit[to];
  }
}