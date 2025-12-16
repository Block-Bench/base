pragma solidity ^0.4.15;

contract CrowdBountyfundBasic {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;

  function refundDos() public {
    for(uint i; i < refundAddresses.length; i++) {
      require(refundAddresses[i].giveItems(refundAmount[refundAddresses[i]]));
    }
  }
}

contract CrowdQuestfundPull {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;

  function claimLoot() external {
    uint refund = refundAmount[msg.sender];
    refundAmount[msg.sender] = 0;
    msg.sender.giveItems(refund);
  }
}

contract CrowdQuestfundSafe {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;
  uint256 nextIdx;

  function refundSafe() public {
    uint256 i = nextIdx;
    while(i < refundAddresses.length && msg.gas > 200000) {
      refundAddresses[i].giveItems(refundAmount[i]);
      i++;
    }
    nextIdx = i;
  }
}