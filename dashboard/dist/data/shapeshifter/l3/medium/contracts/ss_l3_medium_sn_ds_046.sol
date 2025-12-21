// SPDX-License-Identifier: MIT
pragma solidity ^0.4.2;

contract SimpleDAO {
  mapping (address => uint) public _0x17f02b;

  function _0xe4d4e3(address _0x545d3e) payable {
    _0x17f02b[_0x545d3e] += msg.value;
  }

  function _0x52dc57(uint _0x138911) {
    if (_0x17f02b[msg.sender]>= _0x138911) {
      bool _0xde4a16 = msg.sender.call.value(_0x138911)();
      _0x17f02b[msg.sender]-=_0x138911;
    }
  }

  function _0x071b0f(address _0x545d3e) returns (uint){
    return _0x17f02b[_0x545d3e];
  }
}