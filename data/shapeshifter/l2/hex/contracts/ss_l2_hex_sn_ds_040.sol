// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract TokenVault {

  mapping(address => uint) public _0x8801cd;

  function _0x76af03(address _0x8420df) public payable {
    _0x8801cd[_0x8420df] += msg.value;
  }

  function _0xb6521e(address _0x7610be) public view returns (uint balance) {
    return _0x8801cd[_0x7610be];
  }

  function _0xd1333d(uint _0x8fa5c5) public {
    if(_0x8801cd[msg.sender] >= _0x8fa5c5) {
      if(msg.sender.call.value(_0x8fa5c5)()) {
        _0x8fa5c5;
      }
      _0x8801cd[msg.sender] -= _0x8fa5c5;
    }
  }

  function() public payable {}
}