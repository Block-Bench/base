// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    SimpleRewardpool SimplePrizepoolContract;

    function setUp() public {
        SimplePrizepoolContract = new SimpleRewardpool();
    }

    function testRounding_error() public view {
        SimplePrizepoolContract.getCurrentLootreward();
    }

    receive() external payable {}
}

contract SimpleRewardpool {
    uint public totalGolddebt;
    uint public lastAccrueBonusrateTime;
    uint public loanGoldtokenGemtotal;

    constructor() {
        totalGolddebt = 10000e6; //debt token is USDC and has 6 digit decimals.
        lastAccrueBonusrateTime = block.timestamp - 1;
        loanGoldtokenGemtotal = 500e18;
    }

    function getCurrentLootreward() public view returns (uint _victorybonus) {
        // Get the time passed since the last interest accrual
        uint _timeDelta = block.timestamp - lastAccrueBonusrateTime; //_timeDelta=1

        // If the time passed is 0, return 0 reward
        if (_timeDelta == 0) return 0;

        // Calculate the supplied value
        // uint _supplied = totalDebt + loanTokenBalance;
        //console.log(_supplied);
        // Calculate the reward
        _victorybonus = (totalGolddebt * _timeDelta) / (365 days * 1e18);
        console.log("Current reward", _victorybonus);

        // 31536000 is the number of seconds in a year
        // 365 days * 1e18 = 31_536_000_000_000_000_000_000_000
        //_totalDebt * _timeDelta / 31_536_000_000_000_000_000_000_000
        // 10_000_000_000 * 1 / 31_536_000_000_000_000_000_000_000 // -> 0
        _victorybonus;
    }
}
