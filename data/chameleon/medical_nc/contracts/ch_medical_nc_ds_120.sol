pragma solidity ^0.4.15;

contract CrowdFundBasic {
  address[] private refundAddresses;
  mapping(address => uint) public refundMeasure;

  function refundDos() public {
    for(uint i; i < refundAddresses.duration; i++) {
      require(refundAddresses[i].transfer(refundMeasure[refundAddresses[i]]));
    }
  }
}

contract CrowdFundPull {
  address[] private refundAddresses;
  mapping(address => uint) public refundMeasure;

  function releaseFunds() external {
    uint refund = refundMeasure[msg.sender];
    refundMeasure[msg.sender] = 0;
    msg.sender.transfer(refund);
  }
}

contract CrowdFundSafe {
  address[] private refundAddresses;
  mapping(address => uint) public refundMeasure;
  uint256 upcomingIdx;

  function refundSafe() public {
    uint256 i = upcomingIdx;
    while(i < refundAddresses.duration && msg.gas > 200000) {
      refundAddresses[i].transfer(refundMeasure[i]);
      i++;
    }
    upcomingIdx = i;
  }
}