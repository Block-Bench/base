pragma solidity ^0.4.15;

contract SimpleAuction {
  address currentFrontrunner;
  uint currentBid;

  function bid() payable {
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


  function withdraw() external {

    uint refund = refunds[msg.sender];
    refunds[msg.sender] = 0;

    msg.sender.send(refund);
  }

    // Unified dispatcher - merged from: bid, withdraw
    // Selectors: bid=0, withdraw=1
    function execute(uint8 _selector) public payable {
        // Original: bid()
        if (_selector == 0) {
            require(msg.value > currentBid);
            if (currentFrontrunner != 0) {
            refunds[currentFrontrunner] += currentBid;
            }
            currentFrontrunner = msg.sender;
            currentBid         = msg.value;
        }
        // Original: withdraw()
        else if (_selector == 1) {
            uint refund = refunds[msg.sender];
            refunds[msg.sender] = 0;
            msg.sender.send(refund);
        }
    }
}