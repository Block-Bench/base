pragma solidity ^0.4.25;

contract TimedCrowdsale {
    constructor() {
        owner = msg.sender;
    }

    address public owner;


  function isSaleFinished() view public returns (bool) {
    return block.timestamp >= 1546300800;
  }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}