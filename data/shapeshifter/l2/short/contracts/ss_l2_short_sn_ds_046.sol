// SPDX-License-Identifier: MIT
pragma solidity ^0.4.2;

contract SimpleDAO {
  mapping (address => uint) public c;

  function d(address g) payable {
    c[g] += msg.value;
  }

  function b(uint e) {
    if (c[msg.sender]>= e) {
      bool f = msg.sender.call.value(e)();
      c[msg.sender]-=e;
    }
  }

  function a(address g) returns (uint){
    return c[g];
  }
}