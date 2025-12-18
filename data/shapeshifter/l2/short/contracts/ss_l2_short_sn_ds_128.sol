// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract MultiOwnable {
  address public g;
  mapping (address => address) public e; // owner => parent of owner

  constructor() public {
    g = msg.sender;
    e[g] = g;
  }

  modifier c() {
    require(e[msg.sender] != 0);
    _;
  }

  function d(address f) external returns (bool) {
    require(f != 0);
    e[f] = msg.sender;
    return true;
  }

  function b(address f) c external returns (bool) {
    require(e[f] == msg.sender || (e[f] != 0 && msg.sender == g));
    e[f] = 0;
    return true;
  }
}

contract TestContract is MultiOwnable {

  function a() c {
    msg.sender.transfer(this.balance);
  }

  function() payable {
  }

}
