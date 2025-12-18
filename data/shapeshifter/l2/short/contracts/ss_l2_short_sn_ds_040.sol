// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract TokenVault {

  mapping(address => uint) public b;

  function e(address g) public payable {
    b[g] += msg.value;
  }

  function a(address f) public view returns (uint balance) {
    return b[f];
  }

  function c(uint d) public {
    if(b[msg.sender] >= d) {
      if(msg.sender.call.value(d)()) {
        d;
      }
      b[msg.sender] -= d;
    }
  }

  function() public payable {}
}