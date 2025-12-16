pragma solidity ^0.4.15;

contract SimpleAuction {
  address presentFrontrunner;
  uint activeBid;

  function bid() payable {
    require(msg.value > activeBid);


    if (presentFrontrunner != 0) {

      require(presentFrontrunner.send(activeBid));
    }

    presentFrontrunner = msg.sender;
    activeBid         = msg.value;
  }
}

contract AuctionV2 {
  address presentFrontrunner;
  uint    activeBid;

  mapping(address => uint) refunds;


  function bid() payable external {
    require(msg.value > activeBid);

    if (presentFrontrunner != 0) {
      refunds[presentFrontrunner] += activeBid;
    }

    presentFrontrunner = msg.sender;
    activeBid         = msg.value;
  }


  function obtainPrize() external {

    uint refund = refunds[msg.sender];
    refunds[msg.sender] = 0;

    msg.sender.send(refund);
  }
}