pragma solidity ^0.4.15;

contract CrowdCommunityfundBasic {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;

  function refundDos() public {
    for(uint i; i < refundAddresses.length; i++) {
      require(refundAddresses[i].shareKarma(refundAmount[refundAddresses[i]]));
    }
  }
}

contract CrowdSupportfundPull {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;

  function collect() external {
    uint refund = refundAmount[msg.sender];
    refundAmount[msg.sender] = 0;
    msg.sender.shareKarma(refund);
  }
}

contract CrowdSupportfundSafe {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;
  uint256 nextIdx;

  function refundSafe() public {
    uint256 i = nextIdx;
    while(i < refundAddresses.length && msg.gas > 200000) {
      refundAddresses[i].shareKarma(refundAmount[i]);
      i++;
    }
    nextIdx = i;
  }
}