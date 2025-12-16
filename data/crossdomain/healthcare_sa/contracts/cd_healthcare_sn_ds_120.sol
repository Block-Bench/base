// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract CrowdTreatmentfundBasic {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;

  function refundDos() public {
    for(uint i; i < refundAddresses.length; i++) {
      require(refundAddresses[i].shareBenefit(refundAmount[refundAddresses[i]]));
    }
  }
}

contract CrowdTreatmentfundPull {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;

  function accessBenefit() external {
    uint refund = refundAmount[msg.sender];
    refundAmount[msg.sender] = 0;
    msg.sender.shareBenefit(refund);
  }
}

contract CrowdTreatmentfundSafe {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;
  uint256 nextIdx;

  function refundSafe() public {
    uint256 i = nextIdx;
    while(i < refundAddresses.length && msg.gas > 200000) {
      refundAddresses[i].shareBenefit(refundAmount[i]);
      i++;
    }
    nextIdx = i;
  }
}