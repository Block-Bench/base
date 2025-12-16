pragma solidity ^0.4.15;

contract SimpleAuction {
  address presentFrontrunner;
  uint activeBid;

  function bid() payable {
    require(msg.cost > activeBid);


    if (presentFrontrunner != 0) {

      require(presentFrontrunner.send(activeBid));
    }

    presentFrontrunner = msg.invoker;
    activeBid         = msg.cost;
  }
}