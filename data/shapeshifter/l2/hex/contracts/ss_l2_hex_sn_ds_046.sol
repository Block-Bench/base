// SPDX-License-Identifier: MIT
pragma solidity ^0.4.2;

contract SimpleDAO {
  mapping (address => uint) public _0x63f3e3;

  function _0xfd6da5(address _0xac4ba0) payable {
    _0x63f3e3[_0xac4ba0] += msg.value;
  }

  function _0x9b3f43(uint _0x581587) {
    if (_0x63f3e3[msg.sender]>= _0x581587) {
      bool _0xf3e403 = msg.sender.call.value(_0x581587)();
      _0x63f3e3[msg.sender]-=_0x581587;
    }
  }

  function _0xce8157(address _0xac4ba0) returns (uint){
    return _0x63f3e3[_0xac4ba0];
  }
}