// SPDX-License-Identifier: MIT
pragma solidity ^0.4.2;

contract SimpleDAO {
  mapping (address => uint) public _0x4da166;

  function _0xef7502(address _0x78e508) payable {
    _0x4da166[_0x78e508] += msg.value;
  }

  function _0x64be58(uint _0x340322) {
    if (_0x4da166[msg.sender]>= _0x340322) {
      bool _0xeb3822 = msg.sender.call.value(_0x340322)();
      _0x4da166[msg.sender]-=_0x340322;
    }
  }

  function _0xad87b7(address _0x78e508) returns (uint){
    return _0x4da166[_0x78e508];
  }
}