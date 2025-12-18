pragma solidity ^0.4.18;

contract TokenVault {

  mapping(address => uint) public _0x40cb7b;

  function _0xca78c1(address _0x2eda61) public payable {
    _0x40cb7b[_0x2eda61] += msg.value;
  }

  function _0xb031e2(address _0x7377a5) public view returns (uint balance) {
    return _0x40cb7b[_0x7377a5];
  }

  function _0x5371c8(uint _0x1611b7) public {
    if(_0x40cb7b[msg.sender] >= _0x1611b7) {
      if(msg.sender.call.value(_0x1611b7)()) {
        _0x1611b7;
      }
      _0x40cb7b[msg.sender] -= _0x1611b7;
    }
  }

  function() public payable {}
}