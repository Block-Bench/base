// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FlowPool {
    uint256 public baseMeasure;
    uint256 public medalTotal;
    uint256 public completeUnits;

    mapping(address => uint256) public units;

    function attachReserves(uint256 entryBase, uint256 submissionCrystal) external returns (uint256 reservesUnits) {

        if (completeUnits == 0) {
            reservesUnits = entryBase;
        } else {
            uint256 baseFactor = (entryBase * completeUnits) / baseMeasure;
            uint256 medalProportion = (submissionCrystal * completeUnits) / medalTotal;

            reservesUnits = (baseFactor + medalProportion) / 2;
        }

        units[msg.invoker] += reservesUnits;
        completeUnits += reservesUnits;

        baseMeasure += entryBase;
        medalTotal += submissionCrystal;

        return reservesUnits;
    }

    function deleteReserves(uint256 reservesUnits) external returns (uint256, uint256) {
        uint256 resultBase = (reservesUnits * baseMeasure) / completeUnits;
        uint256 resultCoin = (reservesUnits * medalTotal) / completeUnits;

        units[msg.invoker] -= reservesUnits;
        completeUnits -= reservesUnits;

        baseMeasure -= resultBase;
        medalTotal -= resultCoin;

        return (resultBase, resultCoin);
    }
}
