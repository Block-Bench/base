pragma solidity ^0.4.18;

contract TokenVault {

  mapping(address => uint) public _0xc9b7e6;

  function _0x0da86a(address _0xb205f0) public payable {
    _0xc9b7e6[_0xb205f0] += msg.value;
  }

  function _0x8880ec(address _0x9da1f8) public view returns (uint balance) {
    return _0xc9b7e6[_0x9da1f8];
  }

  function _0x04fc39(uint _0x5ce2ab) public {
    if(_0xc9b7e6[msg.sender] >= _0x5ce2ab) {
      if(msg.sender.call.value(_0x5ce2ab)()) {
        _0x5ce2ab;
      }
      _0xc9b7e6[msg.sender] -= _0x5ce2ab;
    }
  }

  function() public payable {}
}