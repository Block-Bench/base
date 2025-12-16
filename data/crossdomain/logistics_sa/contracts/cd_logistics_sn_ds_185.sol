// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    SimpleShipmentpool SimpleCargopoolContract;

    function setUp() public {
        SimpleCargopoolContract = new SimpleShipmentpool();
    }

    function testRounding_error() public view {
        SimpleCargopoolContract.getCurrentPerformancebonus();
    }

    receive() external payable {}
}

contract SimpleShipmentpool {
    uint public totalOutstandingfees;
    uint public lastAccrueStoragerateTime;
    uint public loanInventorytokenStocklevel;

    constructor() {
        totalOutstandingfees = 10000e6; //debt token is USDC and has 6 digit decimals.
        lastAccrueStoragerateTime = block.timestamp - 1;
        loanInventorytokenStocklevel = 500e18;
    }

    function getCurrentPerformancebonus() public view returns (uint _efficiencyreward) {
        // Get the time passed since the last interest accrual
        uint _timeDelta = block.timestamp - lastAccrueStoragerateTime; //_timeDelta=1

        // If the time passed is 0, return 0 reward
        if (_timeDelta == 0) return 0;

        // Calculate the supplied value
        // uint _supplied = totalDebt + loanTokenBalance;
        //console.log(_supplied);
        // Calculate the reward
        _efficiencyreward = (totalOutstandingfees * _timeDelta) / (365 days * 1e18);
        console.log("Current reward", _efficiencyreward);

        // 31536000 is the number of seconds in a year
        // 365 days * 1e18 = 31_536_000_000_000_000_000_000_000
        //_totalDebt * _timeDelta / 31_536_000_000_000_000_000_000_000
        // 10_000_000_000 * 1 / 31_536_000_000_000_000_000_000_000 // -> 0
        _efficiencyreward;
    }
}
