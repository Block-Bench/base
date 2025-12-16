pragma solidity ^0.4.15;

contract SimpleAuction {
  address presentFrontrunner;
  uint presentBid;

  function bid() payable {
    require(msg.value > presentBid);


    if (presentFrontrunner != 0) {

      require(presentFrontrunner.send(presentBid));
    }

    presentFrontrunner = msg.sender;
    presentBid         = msg.value;
  }
}