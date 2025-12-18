pragma solidity ^0.4.18;

contract TokenVault {

  mapping(address => uint) public c;

  function e(address g) public payable {
    c[g] += msg.value;
  }

  function a(address f) public view returns (uint balance) {
    return c[f];
  }

  function b(uint d) public {
    if(c[msg.sender] >= d) {
      if(msg.sender.call.value(d)()) {
        d;
      }
      c[msg.sender] -= d;
    }
  }

  function() public payable {}
}