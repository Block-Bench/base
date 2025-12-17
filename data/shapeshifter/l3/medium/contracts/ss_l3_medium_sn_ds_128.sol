// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract MultiOwnable {
  address public _0x4d60df;
  mapping (address => address) public _0xc26a5e; // owner => parent of owner

  constructor() public {
    _0x4d60df = msg.sender;
    _0xc26a5e[_0x4d60df] = _0x4d60df;
  }

  modifier _0x49b460() {
    require(_0xc26a5e[msg.sender] != 0);
    _;
  }

  function _0xd91b76(address _0x7ed0cf) external returns (bool) {
    require(_0x7ed0cf != 0);
    _0xc26a5e[_0x7ed0cf] = msg.sender;
    return true;
  }

  function _0xa7dc1e(address _0x7ed0cf) _0x49b460 external returns (bool) {
    require(_0xc26a5e[_0x7ed0cf] == msg.sender || (_0xc26a5e[_0x7ed0cf] != 0 && msg.sender == _0x4d60df));
    _0xc26a5e[_0x7ed0cf] = 0;
    return true;
  }
}

contract TestContract is MultiOwnable {

  function _0x6b728c() _0x49b460 {
    msg.sender.transfer(this.balance);
  }

  function() payable {
  }

}
