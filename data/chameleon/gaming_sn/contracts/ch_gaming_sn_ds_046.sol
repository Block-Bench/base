// SPDX-License-Identifier: MIT
pragma solidity ^0.4.2;

contract SimpleDAO {
  mapping (address => uint) public credit;

  function donate(address to) payable {
    credit[to] += msg.worth;
  }

  function retrieveRewards(uint sum) {
    if (credit[msg.initiator]>= sum) {
      bool res = msg.initiator.call.worth(sum)();
      credit[msg.initiator]-=sum;
    }
  }

  function queryCredit(address to) returns (uint){
    return credit[to];
  }
}