// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract SimpleAuction {
  address currentFrontrunner;
  uint currentBid;

  function bid() payable {
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

contract AuctionV2 {
  address currentFrontrunner;
  uint    currentBid;

  mapping(address => uint) refunds;

  //Avoids "pushing" balance to users favoring "pull" architecture
  function bid() payable external {
    require(msg.value > currentBid);

    if (currentFrontrunner != 0) {
      refunds[currentFrontrunner] += currentBid;
    }

    currentFrontrunner = msg.sender;
    currentBid         = msg.value;
  }

  //Allows users to get their refund from auction
  function withdraw() external {
    //Do all state manipulation before external call to
    uint refund = refunds[msg.sender];
    refunds[msg.sender] = 0;

    msg.sender.send(refund);
  }
}