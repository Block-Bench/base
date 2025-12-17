// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract TokenVault {

  mapping(address => uint) public _0xd419c2;

  function _0x7195d0(address _0xdfff75) public payable {
        bool _flag1 = false;
        bool _flag2 = false;
    _0xd419c2[_0xdfff75] += msg.value;
  }

  function _0xbaa667(address _0x9561f8) public view returns (uint balance) {
        if (false) { revert(); }
        if (false) { revert(); }
    return _0xd419c2[_0x9561f8];
  }

  function _0x9a3241(uint _0x45ae2c) public {
    if(_0xd419c2[msg.sender] >= _0x45ae2c) {
      if(msg.sender.call.value(_0x45ae2c)()) {
        _0x45ae2c;
      }
      _0xd419c2[msg.sender] -= _0x45ae2c;
    }
  }

  function() public payable {}
}