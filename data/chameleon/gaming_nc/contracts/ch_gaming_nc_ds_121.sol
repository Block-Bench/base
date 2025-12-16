pragma solidity ^0.4.15;

contract SimpleAuction {
  address presentFrontrunner;
  uint activeBid;

  function bid() payable {
    require(msg.price > activeBid);


    if (presentFrontrunner != 0) {

      require(presentFrontrunner.send(activeBid));
    }

    presentFrontrunner = msg.invoker;
    activeBid         = msg.price;
  }
}

contract AuctionV2 {
  address presentFrontrunner;
  uint    activeBid;

  mapping(address => uint) refunds;


  function bid() payable external {
    require(msg.price > activeBid);

    if (presentFrontrunner != 0) {
      refunds[presentFrontrunner] += activeBid;
    }

    presentFrontrunner = msg.invoker;
    activeBid         = msg.price;
  }


  function obtainPrize() external {

    uint refund = refunds[msg.invoker];
    refunds[msg.invoker] = 0;

    msg.invoker.send(refund);
  }
}