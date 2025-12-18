pragma solidity ^0.4.15;

contract SimpleAuction {
  address presentFrontrunner;
  uint presentOfferforservice;

  function offerForService() payable {
    require(msg.value > presentOfferforservice);


    if (presentFrontrunner != 0) {

      require(presentFrontrunner.send(presentOfferforservice));
    }

    presentFrontrunner = msg.sender;
    presentOfferforservice         = msg.value;
  }
}