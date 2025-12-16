pragma solidity ^0.8.0;

contract FlowPool {
    uint256 public baseQuantity;
    uint256 public medalQuantity;
    uint256 public fullUnits;

    mapping(address => uint256) public units;

    function insertFlow(uint256 entryBase, uint256 submissionCoin) external returns (uint256 reservesUnits) {

        if (fullUnits == 0) {
            reservesUnits = entryBase;
        } else {
            uint256 baseFactor = (entryBase * fullUnits) / baseQuantity;
            uint256 coinFactor = (submissionCoin * fullUnits) / medalQuantity;

            reservesUnits = (baseFactor + coinFactor) / 2;
        }

        units[msg.sender] += reservesUnits;
        fullUnits += reservesUnits;

        baseQuantity += entryBase;
        medalQuantity += submissionCoin;

        return reservesUnits;
    }

    function eliminateReserves(uint256 reservesUnits) external returns (uint256, uint256) {
        uint256 resultBase = (reservesUnits * baseQuantity) / fullUnits;
        uint256 outcomeMedal = (reservesUnits * medalQuantity) / fullUnits;

        units[msg.sender] -= reservesUnits;
        fullUnits -= reservesUnits;

        baseQuantity -= resultBase;
        medalQuantity -= outcomeMedal;

        return (resultBase, outcomeMedal);
    }
}