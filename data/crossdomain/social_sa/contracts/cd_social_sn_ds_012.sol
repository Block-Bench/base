// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Proxy {

  address founder;

  constructor() public {
    founder = msg.sender;
  }

  function forward(address callee, bytes _data) public {
    require(callee.delegatecall(_data));
  }

}