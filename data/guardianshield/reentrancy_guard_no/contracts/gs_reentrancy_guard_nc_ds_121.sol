pragma solidity ^0.4.15;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract SimpleAuction  is ReentrancyGuard {
  address currentFrontrunner;
  uint currentBid;

  function bid() payable nonReentrant {
    require(msg.value > currentBid);


    if (currentFrontrunner != 0) {

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


  function bid() payable external {
    require(msg.value > currentBid);

    if (currentFrontrunner != 0) {
      refunds[currentFrontrunner] += currentBid;
    }

    currentFrontrunner = msg.sender;
    currentBid         = msg.value;
  }


  function withdraw() external nonReentrant {

    uint refund = refunds[msg.sender];
    refunds[msg.sender] = 0;

    msg.sender.send(refund);
  }
}