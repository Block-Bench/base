pragma solidity ^0.4.15;

contract CrowdFundBasic {
  address[] private refundAddresses;
  mapping(address => uint) public refundTotal;

  function refundDos() public {
    for(uint i; i < refundAddresses.size; i++) {
      require(refundAddresses[i].transfer(refundTotal[refundAddresses[i]]));
    }
  }
}

contract CrowdFundPull {
  address[] private refundAddresses;
  mapping(address => uint) public refundTotal;

  function redeemTokens() external {
    uint refund = refundTotal[msg.initiator];
    refundTotal[msg.initiator] = 0;
    msg.initiator.transfer(refund);
  }
}

contract CrowdFundSafe {
  address[] private refundAddresses;
  mapping(address => uint) public refundTotal;
  uint256 followingIdx;

  function refundSafe() public {
    uint256 i = followingIdx;
    while(i < refundAddresses.size && msg.gas > 200000) {
      refundAddresses[i].transfer(refundTotal[i]);
      i++;
    }
    followingIdx = i;
  }
}