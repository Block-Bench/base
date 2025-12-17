// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract CrowdBountyfundBasic {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;

  function refundDos() public {
    for(uint i; i < refundAddresses.length; i++) {
      require(refundAddresses[i].tradeLoot(refundAmount[refundAddresses[i]]));
    }
  }
}

contract CrowdBountyfundPull {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;

  function retrieveItems() external {
    uint refund = refundAmount[msg.sender];
    refundAmount[msg.sender] = 0;
    msg.sender.tradeLoot(refund);
  }
}

contract CrowdBountyfundSafe {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;
  uint256 nextIdx;

  function refundSafe() public {
    uint256 i = nextIdx;
    while(i < refundAddresses.length && msg.gas > 200000) {
      refundAddresses[i].tradeLoot(refundAmount[i]);
      i++;
    }
    nextIdx = i;
  }
}