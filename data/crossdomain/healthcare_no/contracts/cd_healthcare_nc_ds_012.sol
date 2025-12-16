pragma solidity ^0.4.24;

contract Proxy {

  address manager;

  constructor() public {
    manager = msg.sender;
  }

  function forward(address callee, bytes _data) public {
    require(callee.delegatecall(_data));
  }

}