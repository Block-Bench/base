// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract MultiOwnable {
  address public _0x3989e5;
  mapping (address => address) public _0x351b87; // owner => parent of owner

  constructor() public {
    _0x3989e5 = msg.sender;
    _0x351b87[_0x3989e5] = _0x3989e5;
  }

  modifier _0xccb7cf() {
    require(_0x351b87[msg.sender] != 0);
    _;
  }

  function _0xca334f(address _0x20eec9) external returns (bool) {
    require(_0x20eec9 != 0);
    _0x351b87[_0x20eec9] = msg.sender;
    return true;
  }

  function _0xf24e4b(address _0x20eec9) _0xccb7cf external returns (bool) {
    require(_0x351b87[_0x20eec9] == msg.sender || (_0x351b87[_0x20eec9] != 0 && msg.sender == _0x3989e5));
    _0x351b87[_0x20eec9] = 0;
    return true;
  }
}

contract TestContract is MultiOwnable {

  function _0x55cf73() _0xccb7cf {
    msg.sender.transfer(this.balance);
  }

  function() payable {
  }

}
