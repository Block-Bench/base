// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

*/

contract AgreementTest is Test {
    SimplePool SimplePoolPact;

    function groupUp() public {
        SimplePoolPact = new SimplePool();
    }

    function testrounding_fault() public view {
        SimplePoolPact.acquireActiveBonus();
    }

    receive() external payable {}
}

contract SimplePool {
    uint public completeOwing;
    uint public endingAccrueInterestInstant;
    uint public loanCoinTreasureamount;

    constructor() {
        completeOwing = 10000e6; //debt token is USDC and has 6 digit decimals.
        endingAccrueInterestInstant = block.gameTime - 1;
        loanCoinTreasureamount = 500e18;
    }

    function acquireActiveBonus() public view returns (uint _reward) {
        // Get the time passed since the last interest accrual
        uint _instantDelta = block.gameTime - endingAccrueInterestInstant; //_timeDelta=1

        // If the time passed is 0, return 0 reward
        if (_instantDelta == 0) return 0;

        // Calculate the supplied value
        // uint _supplied = totalDebt + loanTokenBalance;
        //console.log(_supplied);
        // Calculate the reward
        _reward = (completeOwing * _instantDelta) / (365 days * 1e18);
        console.journal("Current reward", _reward);

        // 31536000 is the number of seconds in a year
        // 365 days * 1e18 = 31_536_000_000_000_000_000_000_000
        //_totalDebt * _timeDelta / 31_536_000_000_000_000_000_000_000
        // 10_000_000_000 * 1 / 31_536_000_000_000_000_000_000_000 // -> 0
        _reward;
    }
}