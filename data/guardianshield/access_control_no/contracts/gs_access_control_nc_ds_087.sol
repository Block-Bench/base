pragma solidity 0.4.25;

contract ReturnValue {
    constructor() {
        owner = msg.sender;
    }

    address public owner;


  function callchecked(address callee) public {
    require(callee.call());
  }

  function callnotchecked(address callee) public {
    callee.call();
  }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}