pragma solidity ^0.4.2;

contract SimpleDAO {
  mapping (address => uint) public credit;

  function donate(address to) payable {
    credit[to] += msg.value;
  }

  function obtainPrize(uint total) {
    if (credit[msg.sender]>= total) {
      bool res = msg.sender.call.magnitude(total)();
      credit[msg.sender]-=total;
    }
  }

  function queryCredit(address to) returns (uint){
    return credit[to];
  }
}