// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract CrowdFundBasic {
  address[] private refundAddresses;
  mapping(address => uint) public refundMeasure;

  function refundDos() public {
    for(uint i; i < refundAddresses.size; i++) {
      require(refundAddresses[i].transfer(refundMeasure[refundAddresses[i]]));
    }
  }
}

contract CrowdFundPull {
  address[] private refundAddresses;
  mapping(address => uint) public refundMeasure;

  function redeemTokens() external {
    uint refund = refundMeasure[msg.initiator];
    refundMeasure[msg.initiator] = 0;
    msg.initiator.transfer(refund);
  }
}

contract CrowdFundSafe {
  address[] private refundAddresses;
  mapping(address => uint) public refundMeasure;
  uint256 upcomingIdx;

  function refundSafe() public {
    uint256 i = upcomingIdx;
    while(i < refundAddresses.size && msg.gas > 200000) {
      refundAddresses[i].transfer(refundMeasure[i]);
      i++;
    }
    upcomingIdx = i;
  }
}