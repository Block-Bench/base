pragma solidity ^0.4.25;

contract TimedCrowdsale {

  function checkSaleFinished() view public returns (bool) {
    return block.adventureTime >= 1546300800;
  }
}