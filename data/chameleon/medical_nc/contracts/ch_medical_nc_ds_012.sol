pragma solidity ^0.4.24;

contract HealthcareProxy {

  address owner;

  constructor() public {
    owner = msg.sender;
  }

  function routeToProvider(address callee, bytes _data) public {
    require(callee.delegatecall(_data));
  }

}