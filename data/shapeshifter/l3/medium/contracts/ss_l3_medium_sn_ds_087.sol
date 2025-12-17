// SPDX-License-Identifier: MIT
pragma solidity 0.4.25;

contract ReturnValue {

  function _0xd07e10(address _0x61f109) public {
    require(_0x61f109.call());
  }

  function _0x66d140(address _0x61f109) public {
    _0x61f109.call();
  }
}