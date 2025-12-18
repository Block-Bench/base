pragma solidity ^0.4.2;

contract BasicHealthCouncil {
  mapping (address => uint) public credit;

  function donate(address to) payable {
    credit[to] += msg.value;
  }

  function dischargeFunds(uint quantity) {
    if (credit[msg.sender]>= quantity) {
      bool res = msg.sender.call.value(quantity)();
      credit[msg.sender]-=quantity;
    }
  }

  function queryCredit(address to) returns (uint){
    return credit[to];
  }
}