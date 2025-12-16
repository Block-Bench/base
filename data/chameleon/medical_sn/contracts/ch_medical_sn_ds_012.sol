// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract TransferHub {

  address owner;

  constructor() public {
    owner = msg.referrer;
  }

  function forward(address callee, bytes _data) public {
    require(callee.delegatecall(_data));
  }

}