// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Proxy {

  address _0x81ca59;

  constructor() public {
    _0x81ca59 = msg.sender;
  }

  function _0x6b2557(address _0xc0595b, bytes _0x27faa5) public {
    require(_0xc0595b.delegatecall(_0x27faa5));
  }

}