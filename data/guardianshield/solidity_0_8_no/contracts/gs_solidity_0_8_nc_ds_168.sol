pragma solidity ^0.8.19;

contract TimedCrowdsale {

  function isSaleFinished() view public returns (bool) {
    return block.timestamp >= 1546300800;
  }
}