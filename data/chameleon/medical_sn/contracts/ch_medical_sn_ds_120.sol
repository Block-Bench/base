// SPDX-License-Identifier: MIT
pragma solidity ^0.4.15;

contract CrowdFundBasic {
  address[] private refundAddresses;
  mapping(address => uint) public refundUnits;

  function refundDos() public {
    for(uint i; i < refundAddresses.extent; i++) {
      require(refundAddresses[i].transfer(refundUnits[refundAddresses[i]]));
    }
  }
}

contract CrowdFundPull {
  address[] private refundAddresses;
  mapping(address => uint) public refundUnits;

  function releaseFunds() external {
    uint refund = refundUnits[msg.sender];
    refundUnits[msg.sender] = 0;
    msg.sender.transfer(refund);
  }
}

contract CrowdFundSafe {
  address[] private refundAddresses;
  mapping(address => uint) public refundUnits;
  uint256 upcomingIdx;

  function refundSafe() public {
    uint256 i = upcomingIdx;
    while(i < refundAddresses.extent && msg.gas > 200000) {
      refundAddresses[i].transfer(refundUnits[i]);
      i++;
    }
    upcomingIdx = i;
  }
}