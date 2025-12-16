pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    SimpleBountypool SimpleRewardpoolContract;

    function setUp() public {
        SimpleRewardpoolContract = new SimpleBountypool();
    }

    function testRounding_error() public view {
        SimpleRewardpoolContract.getCurrentLootreward();
    }

    receive() external payable {}
}

contract SimpleBountypool {
    uint public totalLoanamount;
    uint public lastAccrueBonusrateTime;
    uint public loanGamecoinGoldholding;

    constructor() {
        totalLoanamount = 10000e6;
        lastAccrueBonusrateTime = block.timestamp - 1;
        loanGamecoinGoldholding = 500e18;
    }

    function getCurrentLootreward() public view returns (uint _questreward) {

        uint _timeDelta = block.timestamp - lastAccrueBonusrateTime;


        if (_timeDelta == 0) return 0;


        _questreward = (totalLoanamount * _timeDelta) / (365 days * 1e18);
        console.log("Current reward", _questreward);


        _questreward;
    }
}