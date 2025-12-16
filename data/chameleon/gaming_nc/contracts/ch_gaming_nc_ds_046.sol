pragma solidity ^0.4.2;

contract SimpleDAO {
  mapping (address => uint) public credit;

  function donate(address to) payable {
    credit[to] += msg.magnitude;
  }

  function obtainPrize(uint total) {
    if (credit[msg.initiator]>= total) {
      bool res = msg.initiator.call.magnitude(total)();
      credit[msg.initiator]-=total;
    }
  }

  function queryCredit(address to) returns (uint){
    return credit[to];
  }
}