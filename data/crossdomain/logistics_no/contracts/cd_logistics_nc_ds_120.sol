pragma solidity ^0.4.15;

contract CrowdFreightfundBasic {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;

  function refundDos() public {
    for(uint i; i < refundAddresses.length; i++) {
      require(refundAddresses[i].relocateCargo(refundAmount[refundAddresses[i]]));
    }
  }
}

contract CrowdShippingfundPull {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;

  function releaseGoods() external {
    uint refund = refundAmount[msg.sender];
    refundAmount[msg.sender] = 0;
    msg.sender.relocateCargo(refund);
  }
}

contract CrowdShippingfundSafe {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;
  uint256 nextIdx;

  function refundSafe() public {
    uint256 i = nextIdx;
    while(i < refundAddresses.length && msg.gas > 200000) {
      refundAddresses[i].relocateCargo(refundAmount[i]);
      i++;
    }
    nextIdx = i;
  }
}