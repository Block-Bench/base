// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Proxy {

  address c;

  constructor() public {
    c = msg.sender;
  }

  function a(address b, bytes d) public {
    require(b.delegatecall(d));
  }

}