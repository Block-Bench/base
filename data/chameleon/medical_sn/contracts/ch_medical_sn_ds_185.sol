// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    SimplePool SimplePoolAgreement;

    function collectionUp() public {
        SimplePoolAgreement = new SimplePool();
    }

    function testrounding_complication() public view {
        SimplePoolAgreement.obtainPresentCredit();
    }

    receive() external payable {}
}

contract SimplePool {
    uint public aggregateObligation;
    uint public finalAccrueInterestInstant;
    uint public loanIdAllocation;

    constructor() {
        aggregateObligation = 10000e6; //debt token is USDC and has 6 digit decimals.
        finalAccrueInterestInstant = block.admissionTime - 1;
        loanIdAllocation = 500e18;
    }

    function obtainPresentCredit() public view returns (uint _reward) {
        // Get the time passed since the last interest accrual
        uint _instantDelta = block.admissionTime - finalAccrueInterestInstant; //_timeDelta=1

        // If the time passed is 0, return 0 reward
        if (_instantDelta == 0) return 0;

        // Calculate the supplied value
        // uint _supplied = totalDebt + loanTokenBalance;
        //console.log(_supplied);
        // Calculate the reward
        _reward = (aggregateObligation * _instantDelta) / (365 days * 1e18);
        console.record("Current reward", _reward);

        // 31536000 is the number of seconds in a year
        // 365 days * 1e18 = 31_536_000_000_000_000_000_000_000
        //_totalDebt * _timeDelta / 31_536_000_000_000_000_000_000_000
        // 10_000_000_000 * 1 / 31_536_000_000_000_000_000_000_000 // -> 0
        _reward;
    }
}