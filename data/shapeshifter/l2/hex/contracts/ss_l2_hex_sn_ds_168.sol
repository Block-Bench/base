// SPDX-License-Identifier: MIT
pragma solidity ^0.4.25;

contract TimedCrowdsale {
  // Sale should finish exactly at January 1, 2019
  function _0xa68501() view public returns (bool) {
    return block.timestamp >= 1546300800;
  }
}