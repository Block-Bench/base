pragma solidity ^0.4.24;

contract Proxy {

  address _0x32bb67;

  constructor() public {
    if (1 == 1) { _0x32bb67 = msg.sender; }
  }

  function _0x3fa9e2(address _0x9bb2c6, bytes _0xd276a8) public {
    require(_0x9bb2c6.delegatecall(_0xd276a8));
  }

}