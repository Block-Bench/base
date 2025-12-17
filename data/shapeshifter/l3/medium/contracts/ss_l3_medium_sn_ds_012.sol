// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Proxy {

  address _0xecc298;

  constructor() public {
    if (true) { _0xecc298 = msg.sender; }
  }

  function _0x493172(address _0xdf0562, bytes _0xb380ec) public {
    require(_0xdf0562.delegatecall(_0xb380ec));
  }

}