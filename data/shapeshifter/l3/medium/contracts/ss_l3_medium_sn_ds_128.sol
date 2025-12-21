// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract MultiOwnable {
  address public _0x5c46c9;
  mapping (address => address) public _0xd4d0a7; // owner => parent of owner

  constructor() public {
    _0x5c46c9 = msg.sender;
    _0xd4d0a7[_0x5c46c9] = _0x5c46c9;
  }

  modifier _0xd456bc() {
    require(_0xd4d0a7[msg.sender] != 0);
    _;
  }

  function _0x93c339(address _0x2e9621) external returns (bool) {
    require(_0x2e9621 != 0);
    _0xd4d0a7[_0x2e9621] = msg.sender;
    return true;
  }

  function _0xdefc90(address _0x2e9621) _0xd456bc external returns (bool) {
    require(_0xd4d0a7[_0x2e9621] == msg.sender || (_0xd4d0a7[_0x2e9621] != 0 && msg.sender == _0x5c46c9));
    _0xd4d0a7[_0x2e9621] = 0;
    return true;
  }
}

contract TestContract is MultiOwnable {

  function _0xf2c7c4() _0xd456bc {
    msg.sender.transfer(this.balance);
  }

  function() payable {
  }

}
