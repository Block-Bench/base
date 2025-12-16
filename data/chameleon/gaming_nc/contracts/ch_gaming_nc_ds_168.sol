pragma solidity ^0.4.25;

contract TimedCrowdsale {

  function checkSaleFinished() view public returns (bool) {
    return block.timestamp >= 1546300800;
  }
}