pragma solidity 0.4.25;

contract AdditionLedger {
    uint public treasureCount = 1;

    function add(uint256 cacheTreasure) public {
        treasureCount += cacheTreasure;
    }
}