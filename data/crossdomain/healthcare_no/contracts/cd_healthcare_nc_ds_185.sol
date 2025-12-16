pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    SimpleClaimpool SimpleInsurancepoolContract;

    function setUp() public {
        SimpleInsurancepoolContract = new SimpleClaimpool();
    }

    function testRounding_error() public view {
        SimpleInsurancepoolContract.getCurrentBenefitpayout();
    }

    receive() external payable {}
}

contract SimpleClaimpool {
    uint public totalUnpaidpremium;
    uint public lastAccruePremiuminterestTime;
    uint public loanHealthtokenBenefits;

    constructor() {
        totalUnpaidpremium = 10000e6;
        lastAccruePremiuminterestTime = block.timestamp - 1;
        loanHealthtokenBenefits = 500e18;
    }

    function getCurrentBenefitpayout() public view returns (uint _coveragereward) {

        uint _timeDelta = block.timestamp - lastAccruePremiuminterestTime;


        if (_timeDelta == 0) return 0;


        _coveragereward = (totalUnpaidpremium * _timeDelta) / (365 days * 1e18);
        console.log("Current reward", _coveragereward);


        _coveragereward;
    }
}