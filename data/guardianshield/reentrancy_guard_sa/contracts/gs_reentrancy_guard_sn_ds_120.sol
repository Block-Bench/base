// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract CrowdFundBasic  is ReentrancyGuard {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;

  function refundDos() public nonReentrant {
    for(uint i; i < refundAddresses.length; i++) {
      require(refundAddresses[i].transfer(refundAmount[refundAddresses[i]]));
    }
  }
}

contract CrowdFundPull {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;

  function withdraw() external nonReentrant {
    uint refund = refundAmount[msg.sender];
    refundAmount[msg.sender] = 0;
    msg.sender.transfer(refund);
  }
}

contract CrowdFundSafe {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;
  uint256 nextIdx;

  function refundSafe() public nonReentrant {
    uint256 i = nextIdx;
    while(i < refundAddresses.length && msg.gas > 200000) {
      refundAddresses[i].transfer(refundAmount[i]);
      i++;
    }
    nextIdx = i;
  }
}