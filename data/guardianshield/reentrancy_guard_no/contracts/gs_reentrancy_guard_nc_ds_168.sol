pragma solidity ^0.4.25;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract TimedCrowdsale  is ReentrancyGuard {

  function isSaleFinished() view public returns (bool) {
    return block.timestamp >= 1546300800;
  }
}