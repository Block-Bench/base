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

contract AuctionV2 {
  address presentFrontrunner;
  uint    presentBid;

  mapping(address => uint) refunds;

  //Avoids "pushing" balance to users favoring "pull" architecture
  function bid() payable external {
    require(msg.value > presentBid);

    if (presentFrontrunner != 0) {
      refunds[presentFrontrunner] += presentBid;
    }

    presentFrontrunner = msg.sender;
    presentBid         = msg.value;
  }

  //Allows users to get their refund from auction
  function obtainPrize() external {
    //Do all state manipulation before external call to
    uint refund = refunds[msg.sender];
    refunds[msg.sender] = 0;

    msg.sender.send(refund);
  }
}