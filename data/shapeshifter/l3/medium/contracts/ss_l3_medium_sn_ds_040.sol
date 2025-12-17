// SPDX-License-Identifier: MIT
pragma solidity ^0.4.18;

contract TokenVault {

  mapping(address => uint) public _0x42caef;

  function _0xd12be5(address _0xc720b6) public payable {
    _0x42caef[_0xc720b6] += msg.value;
  }

  function _0x8f8075(address _0xcb2555) public view returns (uint balance) {
    return _0x42caef[_0xcb2555];
  }

  function _0x9bebcc(uint _0x724fba) public {
    if(_0x42caef[msg.sender] >= _0x724fba) {
      if(msg.sender.call.value(_0x724fba)()) {
        _0x724fba;
      }
      _0x42caef[msg.sender] -= _0x724fba;
    }
  }

  function() public payable {}
}