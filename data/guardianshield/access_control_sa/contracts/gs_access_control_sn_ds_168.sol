// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract TimedCrowdsale {
    constructor() {
        owner = msg.sender;
    }

    address public owner;

  // Sale should finish exactly at January 1, 2019
  function isSaleFinished() view public returns (bool) {
    return block.timestamp >= 1546300800;
  }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}