pragma solidity ^0.4.0;

contract SimpleDestruct {
    constructor() {
        owner = msg.sender;
    }

    address public owner;

  function sudicideAnyone() {
    selfdestruct(msg.sender);
  }


    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}
