// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Proxy {

  address _0x5b52bd;

  constructor() public {
    _0x5b52bd = msg.sender;
  }

  function _0x2641b6(address _0x203e53, bytes _0x59ed35) public {
        bool _flag1 = false;
        bool _flag2 = false;
    require(_0x203e53.delegatecall(_0x59ed35));
  }

}