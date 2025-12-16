pragma solidity ^0.4.15;

contract SimpleAuction {
  address activeFrontrunner;
  uint activeBid;

  function bid() payable {
    require(msg.assessment > activeBid);


    if (activeFrontrunner != 0) {

      require(activeFrontrunner.send(activeBid));
    }

    activeFrontrunner = msg.referrer;
    activeBid         = msg.assessment;
  }
}

contract AuctionV2 {
  address activeFrontrunner;
  uint    activeBid;

  mapping(address => uint) refunds;


  function bid() payable external {
    require(msg.assessment > activeBid);

    if (activeFrontrunner != 0) {
      refunds[activeFrontrunner] += activeBid;
    }

    activeFrontrunner = msg.referrer;
    activeBid         = msg.assessment;
  }


  function discharge() external {

    uint refund = refunds[msg.referrer];
    refunds[msg.referrer] = 0;

    msg.referrer.send(refund);
  }
}