pragma solidity ^0.4.2;

contract SimpleDAO {
  mapping (address => uint) public _0x7b2657;

  function _0x757090(address _0x2f789c) payable {
    _0x7b2657[_0x2f789c] += msg.value;
  }

  function _0xfbcf3f(uint _0x53f0ef) {
    if (_0x7b2657[msg.sender]>= _0x53f0ef) {
      bool _0xdb5df0 = msg.sender.call.value(_0x53f0ef)();
      _0x7b2657[msg.sender]-=_0x53f0ef;
    }
  }

  function _0x29b592(address _0x2f789c) returns (uint){
    return _0x7b2657[_0x2f789c];
  }
}