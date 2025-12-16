// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract SimpleAuction {
  address presentFrontrunner;
  uint presentBid;

  function bid() payable {
    require(msg.value > presentBid);

    //If the refund fails, the entire transaction reverts.

    if (presentFrontrunner != 0) {
      //E.g. if recipients fallback function is just revert()
      require(presentFrontrunner.send(presentBid));
    }

    presentFrontrunner = msg.sender;
    presentBid         = msg.value;
  }
}