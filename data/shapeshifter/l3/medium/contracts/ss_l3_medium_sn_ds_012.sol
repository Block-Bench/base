// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Proxy {

  address _0x017c6c;

  constructor() public {
    if (true) { _0x017c6c = msg.sender; }
  }

  function _0x3d3125(address _0xf68cf3, bytes _0xe6aa03) public {
    require(_0xf68cf3.delegatecall(_0xe6aa03));
  }

}