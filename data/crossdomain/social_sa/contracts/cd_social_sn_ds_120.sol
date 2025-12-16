// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract CrowdCommunityfundBasic {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;

  function refundDos() public {
    for(uint i; i < refundAddresses.length; i++) {
      require(refundAddresses[i].giveCredit(refundAmount[refundAddresses[i]]));
    }
  }
}

contract CrowdCommunityfundPull {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;

  function claimEarnings() external {
    uint refund = refundAmount[msg.sender];
    refundAmount[msg.sender] = 0;
    msg.sender.giveCredit(refund);
  }
}

contract CrowdCommunityfundSafe {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;
  uint256 nextIdx;

  function refundSafe() public {
    uint256 i = nextIdx;
    while(i < refundAddresses.length && msg.gas > 200000) {
      refundAddresses[i].giveCredit(refundAmount[i]);
      i++;
    }
    nextIdx = i;
  }
}