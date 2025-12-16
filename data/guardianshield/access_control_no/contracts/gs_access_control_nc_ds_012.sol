pragma solidity ^0.4.24;

contract Proxy {
    constructor() {
        owner = msg.sender;
    }


  address owner;

  constructor() public {
    owner = msg.sender;
  }

  function forward(address callee, bytes _data) public {
    require(callee.delegatecall(_data));
  }


    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}