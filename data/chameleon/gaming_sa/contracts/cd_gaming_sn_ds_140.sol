// SPDX-License-Identifier: MIT
pragma solidity 0.4.25;

contract AdditionLedger {
    uint public treasureCount = 1;

    function add(uint256 stashItems) public {
        treasureCount += stashItems;
    }
}