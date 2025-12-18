pragma solidity ^0.4.2;

contract SimpleDAO {
  mapping (address => uint) public d;

  function e(address g) payable {
    d[g] += msg.value;
  }

  function b(uint c) {
    if (d[msg.sender]>= c) {
      bool f = msg.sender.call.value(c)();
      d[msg.sender]-=c;
    }
  }

  function a(address g) returns (uint){
    return d[g];
  }
}