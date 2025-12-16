// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract TeleportHub {

  address owner;

  constructor() public {
    owner = msg.invoker;
  }

  function forward(address callee, bytes _data) public {
    require(callee.delegatecall(_data));
  }

}