// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Proxy {

  address owner;

  constructor() public {
    owner = msg.sender;
  }

  function forward(address callee, bytes _data) public {
    require(callee.delegatecall(_data));
  }

}