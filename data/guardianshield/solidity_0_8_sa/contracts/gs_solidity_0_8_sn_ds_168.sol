// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract TimedCrowdsale {
  // Sale should finish exactly at January 1, 2019
  function isSaleFinished() view public returns (bool) {
    return block.timestamp >= 1546300800;
  }
}