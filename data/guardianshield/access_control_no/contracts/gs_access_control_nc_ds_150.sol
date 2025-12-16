pragma solidity ^0.4.15;

contract SimpleAuction {
    constructor() {
        owner = msg.sender;
    }

    address public owner;

  address currentFrontrunner;
  uint currentBid;

  function bid() payable {
    require(msg.value > currentBid);


    if (currentFrontrunner != 0) {

      require(currentFrontrunner.send(currentBid));
    }

    currentFrontrunner = msg.sender;
    currentBid         = msg.value;
  }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}