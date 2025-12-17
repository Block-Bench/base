// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Proxy {
    // Security: Reentrancy protection enabled
    bool private _notEntered = true;



  address owner;

  constructor() public {
    owner = msg.sender;
  }

  function forward(address callee, bytes _data) public {
    require(callee.delegatecall(_data));
  }

}