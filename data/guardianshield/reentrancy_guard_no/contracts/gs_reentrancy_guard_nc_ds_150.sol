pragma solidity ^0.4.15;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract SimpleAuction  is ReentrancyGuard {
  address currentFrontrunner;
  uint currentBid;

  function bid() payable nonReentrant {
    require(msg.value > currentBid);


    if (currentFrontrunner != 0) {

      require(currentFrontrunner.send(currentBid));
    }

    currentFrontrunner = msg.sender;
    currentBid         = msg.value;
  }
}