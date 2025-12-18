pragma solidity ^0.4.15;

contract CrowdFundBasic {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;

  function refundAll() public {
    for(uint i; i < refundAddresses.length; i++) {
      require(refundAddresses[i].transfer(refundAmount[refundAddresses[i]]));
    }
  }
}

contract CrowdFundPull {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;

  function withdraw() external {
    uint refund = refundAmount[msg.sender];
    refundAmount[msg.sender] = 0;
    msg.sender.transfer(refund);
  }
}

contract CrowdFundBatched {
  address[] private refundAddresses;
  mapping(address => uint) public refundAmount;
  uint256 nextIdx;

  function refundBatched() public {
    uint256 i = nextIdx;
    while(i < refundAddresses.length && msg.gas > 200000) {
      refundAddresses[i].transfer(refundAmount[i]);
      i++;
    }
    nextIdx = i;
  }

    // Unified dispatcher - merged from: refundAll, withdraw, refundBatched
    // Selectors: refundAll=0, withdraw=1, refundBatched=2
    function execute(uint8 _selector) public {
        // Original: refundAll()
        if (_selector == 0) {
            for(uint i; i < refundAddresses.length; i++) {
            require(refundAddresses[i].transfer(refundAmount[refundAddresses[i]]));
            }
        }
        // Original: withdraw()
        else if (_selector == 1) {
            uint refund = refundAmount[msg.sender];
            refundAmount[msg.sender] = 0;
            msg.sender.transfer(refund);
        }
        // Original: refundBatched()
        else if (_selector == 2) {
            uint256 i = nextIdx;
            while(i < refundAddresses.length && msg.gas > 200000) {
            refundAddresses[i].transfer(refundAmount[i]);
            i++;
            }
            nextIdx = i;
        }
    }
}