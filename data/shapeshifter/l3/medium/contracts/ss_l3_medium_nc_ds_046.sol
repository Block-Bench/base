pragma solidity ^0.4.2;

contract SimpleDAO {
  mapping (address => uint) public _0xdb347c;

  function _0x87a7a4(address _0xf2aa20) payable {
    _0xdb347c[_0xf2aa20] += msg.value;
  }

  function _0x4bebc2(uint _0x5e0bd2) {
    if (_0xdb347c[msg.sender]>= _0x5e0bd2) {
      bool _0x0eda0b = msg.sender.call.value(_0x5e0bd2)();
      _0xdb347c[msg.sender]-=_0x5e0bd2;
    }
  }

  function _0x1386b0(address _0xf2aa20) returns (uint){
    return _0xdb347c[_0xf2aa20];
  }
}