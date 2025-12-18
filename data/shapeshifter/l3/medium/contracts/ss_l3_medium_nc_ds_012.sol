pragma solidity ^0.4.24;

contract Proxy {

  address _0x23dbe2;

  constructor() public {
    _0x23dbe2 = msg.sender;
  }

  function _0x7f0de0(address _0x55ffcd, bytes _0x483b74) public {
    require(_0x55ffcd.delegatecall(_0x483b74));
  }

}