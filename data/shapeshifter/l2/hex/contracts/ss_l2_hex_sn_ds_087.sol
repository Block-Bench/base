// SPDX-License-Identifier: MIT
pragma solidity 0.4.25;

contract ReturnValue {

  function _0xc100dd(address _0xb002bd) public {
    require(_0xb002bd.call());
  }

  function _0x2b6618(address _0xb002bd) public {
    _0xb002bd.call();
  }
}