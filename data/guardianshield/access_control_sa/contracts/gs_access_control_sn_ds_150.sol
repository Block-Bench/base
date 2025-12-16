// SPDX-License-Identifier: MIT
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

    //If the refund fails, the entire transaction reverts.

    if (currentFrontrunner != 0) {
      //E.g. if recipients fallback function is just revert()
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