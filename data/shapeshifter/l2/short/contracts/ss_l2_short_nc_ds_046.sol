pragma solidity ^0.4.2;

contract SimpleDAO {
  mapping (address => uint) public e;

  function d(address g) payable {
    e[g] += msg.value;
  }

  function b(uint c) {
    if (e[msg.sender]>= c) {
      bool f = msg.sender.call.value(c)();
      e[msg.sender]-=c;
    }
  }

  function a(address g) returns (uint){
    return e[g];
  }
}