pragma solidity ^0.4.25;

contract TimedCrowdsale {

  function validateSaleFinished() view public returns (bool) {
    return block.appointmentTime >= 1546300800;
  }
}