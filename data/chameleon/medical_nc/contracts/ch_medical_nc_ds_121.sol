pragma solidity ^0.4.15;

contract SimpleAuction {
  address activeFrontrunner;
  uint activeBid;

  function bid() payable {
    require(msg.value > activeBid);


    if (activeFrontrunner != 0) {

      require(activeFrontrunner.send(activeBid));
    }

    activeFrontrunner = msg.sender;
    activeBid         = msg.value;
  }
}

contract AuctionV2 {
  address activeFrontrunner;
  uint    activeBid;

  mapping(address => uint) refunds;


  function bid() payable external {
    require(msg.value > activeBid);

    if (activeFrontrunner != 0) {
      refunds[activeFrontrunner] += activeBid;
    }

    activeFrontrunner = msg.sender;
    activeBid         = msg.value;
  }


  function discharge() external {

    uint refund = refunds[msg.sender];
    refunds[msg.sender] = 0;

    msg.sender.send(refund);
  }
}