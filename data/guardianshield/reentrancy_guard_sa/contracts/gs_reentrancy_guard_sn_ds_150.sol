// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract SimpleAuction  is ReentrancyGuard {
  address currentFrontrunner;
  uint currentBid;

  function bid() payable nonReentrant {
    require(msg.value > currentBid);

    //If the refund fails, the entire transaction reverts.

    if (currentFrontrunner != 0) {
      //E.g. if recipients fallback function is just revert()
      require(currentFrontrunner.send(currentBid));
    }

    currentFrontrunner = msg.sender;
    currentBid         = msg.value;
  }
}