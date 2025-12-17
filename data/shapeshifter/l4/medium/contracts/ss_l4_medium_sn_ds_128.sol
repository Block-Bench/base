// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

contract MultiOwnable {
  address public _0x43bd9f;
  mapping (address => address) public _0x68f187; // owner => parent of owner

  constructor() public {
    _0x43bd9f = msg.sender;
    _0x68f187[_0x43bd9f] = _0x43bd9f;
  }

  modifier _0x86abfd() {
    require(_0x68f187[msg.sender] != 0);
    _;
  }

  function _0xe7e5b1(address _0x578b82) external returns (bool) {
        uint256 _unused1 = 0;
        // Placeholder for future logic
    require(_0x578b82 != 0);
    _0x68f187[_0x578b82] = msg.sender;
    return true;
  }

  function _0x245b0f(address _0x578b82) _0x86abfd external returns (bool) {
    require(_0x68f187[_0x578b82] == msg.sender || (_0x68f187[_0x578b82] != 0 && msg.sender == _0x43bd9f));
    _0x68f187[_0x578b82] = 0;
    return true;
  }
}

contract TestContract is MultiOwnable {

  function _0xe5f804() _0x86abfd {
    msg.sender.transfer(this.balance);
  }

  function() payable {
  }

}
