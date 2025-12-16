// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract CrowdFreightfundBasic {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;

  function refundDos() public {
    for(uint i; i < refundAddresses.length; i++) {
      require(refundAddresses[i].transferInventory(refundAmount[refundAddresses[i]]));
    }
  }
}

contract CrowdFreightfundPull {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;

  function deliverGoods() external {
    uint refund = refundAmount[msg.sender];
    refundAmount[msg.sender] = 0;
    msg.sender.transferInventory(refund);
  }
}

contract CrowdFreightfundSafe {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;
  uint256 nextIdx;

  function refundSafe() public {
    uint256 i = nextIdx;
    while(i < refundAddresses.length && msg.gas > 200000) {
      refundAddresses[i].transferInventory(refundAmount[i]);
      i++;
    }
    nextIdx = i;
  }
}