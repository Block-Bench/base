pragma solidity ^0.4.24;

contract Proxy {

  address groupOwner;

  constructor() public {
    groupOwner = msg.sender;
  }

  function forward(address callee, bytes _data) public {
    require(callee.delegatecall(_data));
  }

}