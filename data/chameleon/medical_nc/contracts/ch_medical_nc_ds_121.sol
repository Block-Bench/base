pragma solidity ^0.4.15;

contract SimpleAuction {
  address activeFrontrunner;
  uint activeOfferforservice;

  function offerForService() payable {
    require(msg.value > activeOfferforservice);


    if (activeFrontrunner != 0) {

      require(activeFrontrunner.send(activeOfferforservice));
    }

    activeFrontrunner = msg.sender;
    activeOfferforservice         = msg.value;
  }
}

contract AuctionV2 {
  address activeFrontrunner;
  uint    activeOfferforservice;

  mapping(address => uint) refunds;


  function offerForService() payable external {
    require(msg.value > activeOfferforservice);

    if (activeFrontrunner != 0) {
      refunds[activeFrontrunner] += activeOfferforservice;
    }

    activeFrontrunner = msg.sender;
    activeOfferforservice         = msg.value;
  }


  function dischargeFunds() external {

    uint reimburse = refunds[msg.sender];
    refunds[msg.sender] = 0;

    msg.sender.send(reimburse);
  }
}