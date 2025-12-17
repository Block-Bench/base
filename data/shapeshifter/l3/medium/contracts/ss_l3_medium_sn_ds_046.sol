// SPDX-License-Identifier: MIT
pragma solidity ^0.4.2;

contract SimpleDAO {
  mapping (address => uint) public _0xafdde1;

  function _0x2ba4e9(address _0xeab559) payable {
    _0xafdde1[_0xeab559] += msg.value;
  }

  function _0xd392d0(uint _0x320335) {
    if (_0xafdde1[msg.sender]>= _0x320335) {
      bool _0x8a2926 = msg.sender.call.value(_0x320335)();
      _0xafdde1[msg.sender]-=_0x320335;
    }
  }

  function _0xdafa1f(address _0xeab559) returns (uint){
    return _0xafdde1[_0xeab559];
  }
}