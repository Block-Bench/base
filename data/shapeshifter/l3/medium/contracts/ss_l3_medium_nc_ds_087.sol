pragma solidity 0.4.25;

contract ReturnValue {

  function _0x251ba4(address _0xc5fa75) public {
    require(_0xc5fa75.call());
  }

  function _0xb90222(address _0xc5fa75) public {
    _0xc5fa75.call();
  }
}