// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    SimpleInsurancepool SimpleBenefitpoolContract;

    function setUp() public {
        SimpleBenefitpoolContract = new SimpleInsurancepool();
    }

    function testRounding_error() public view {
        SimpleBenefitpoolContract.getCurrentCoveragereward();
    }

    receive() external payable {}
}

contract SimpleInsurancepool {
    uint public totalOutstandingbalance;
    uint public lastAccruePremiuminterestTime;
    uint public loanCoveragetokenBenefits;

    constructor() {
        totalOutstandingbalance = 10000e6; //debt token is USDC and has 6 digit decimals.
        lastAccruePremiuminterestTime = block.timestamp - 1;
        loanCoveragetokenBenefits = 500e18;
    }

    function getCurrentCoveragereward() public view returns (uint _claimpayment) {
        // Get the time passed since the last interest accrual
        uint _timeDelta = block.timestamp - lastAccruePremiuminterestTime; //_timeDelta=1

        // If the time passed is 0, return 0 reward
        if (_timeDelta == 0) return 0;

        // Calculate the supplied value
        // uint _supplied = totalDebt + loanTokenBalance;
        //console.log(_supplied);
        // Calculate the reward
        _claimpayment = (totalOutstandingbalance * _timeDelta) / (365 days * 1e18);
        console.log("Current reward", _claimpayment);

        // 31536000 is the number of seconds in a year
        // 365 days * 1e18 = 31_536_000_000_000_000_000_000_000
        //_totalDebt * _timeDelta / 31_536_000_000_000_000_000_000_000
        // 10_000_000_000 * 1 / 31_536_000_000_000_000_000_000_000 // -> 0
        _claimpayment;
    }
}
