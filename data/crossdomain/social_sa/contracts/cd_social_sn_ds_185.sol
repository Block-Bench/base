// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    SimpleTippool SimpleSupportpoolContract;

    function setUp() public {
        SimpleSupportpoolContract = new SimpleTippool();
    }

    function testRounding_error() public view {
        SimpleSupportpoolContract.getCurrentTipreward();
    }

    receive() external payable {}
}

contract SimpleTippool {
    uint public totalNegativekarma;
    uint public lastAccrueGrowthrateTime;
    uint public loanReputationtokenStanding;

    constructor() {
        totalNegativekarma = 10000e6; //debt token is USDC and has 6 digit decimals.
        lastAccrueGrowthrateTime = block.timestamp - 1;
        loanReputationtokenStanding = 500e18;
    }

    function getCurrentTipreward() public view returns (uint _communityreward) {
        // Get the time passed since the last interest accrual
        uint _timeDelta = block.timestamp - lastAccrueGrowthrateTime; //_timeDelta=1

        // If the time passed is 0, return 0 reward
        if (_timeDelta == 0) return 0;

        // Calculate the supplied value
        // uint _supplied = totalDebt + loanTokenBalance;
        //console.log(_supplied);
        // Calculate the reward
        _communityreward = (totalNegativekarma * _timeDelta) / (365 days * 1e18);
        console.log("Current reward", _communityreward);

        // 31536000 is the number of seconds in a year
        // 365 days * 1e18 = 31_536_000_000_000_000_000_000_000
        //_totalDebt * _timeDelta / 31_536_000_000_000_000_000_000_000
        // 10_000_000_000 * 1 / 31_536_000_000_000_000_000_000_000 // -> 0
        _communityreward;
    }
}
