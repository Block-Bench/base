pragma solidity ^0.4.24;

contract Proxy {

  address gamemaster;

  constructor() public {
    gamemaster = msg.sender;
  }

  function forward(address callee, bytes _data) public {
    require(callee.delegatecall(_data));
  }

}