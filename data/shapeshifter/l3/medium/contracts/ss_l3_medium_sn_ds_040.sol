// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract TokenVault {

  mapping(address => uint) public _0x3d947c;

  function _0xe6c234(address _0x3304aa) public payable {
    _0x3d947c[_0x3304aa] += msg.value;
  }

  function _0x6b764e(address _0x2beead) public view returns (uint balance) {
    return _0x3d947c[_0x2beead];
  }

  function _0x294e80(uint _0x001c8e) public {
    if(_0x3d947c[msg.sender] >= _0x001c8e) {
      if(msg.sender.call.value(_0x001c8e)()) {
        _0x001c8e;
      }
      _0x3d947c[msg.sender] -= _0x001c8e;
    }
  }

  function() public payable {}
}