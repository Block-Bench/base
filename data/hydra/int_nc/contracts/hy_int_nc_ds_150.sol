pragma solidity ^0.4.15;

contract SimpleAuction {
  address currentFrontrunner;
  uint currentBid;

  function bid() payable {
        _performBidInternal(msg.sender);
    }

    function _performBidInternal(address _sender) internal {
        require(msg.value > currentBid);
        if (currentFrontrunner != 0) {
        require(currentFrontrunner.send(currentBid));
        }
        currentFrontrunner = _sender;
        currentBid         = msg.value;
    }
}