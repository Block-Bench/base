// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AvailablegoldPrizepool {
    uint256 public baseAmount;
    uint256 public questtokenAmount;
    uint256 public totalUnits;

    mapping(address => uint256) public units;

    function addAvailablegold(uint256 inputBase, uint256 inputQuesttoken) external returns (uint256 availablegoldUnits) {

        if (totalUnits == 0) {
            availablegoldUnits = inputBase;
        } else {
            uint256 baseRatio = (inputBase * totalUnits) / baseAmount;
            uint256 realmcoinRatio = (inputQuesttoken * totalUnits) / questtokenAmount;

            availablegoldUnits = (baseRatio + realmcoinRatio) / 2;
        }

        units[msg.sender] += availablegoldUnits;
        totalUnits += availablegoldUnits;

        baseAmount += inputBase;
        questtokenAmount += inputQuesttoken;

        return availablegoldUnits;
    }

    function removeTradableassets(uint256 availablegoldUnits) external returns (uint256, uint256) {
        uint256 outputBase = (availablegoldUnits * baseAmount) / totalUnits;
        uint256 outputQuesttoken = (availablegoldUnits * questtokenAmount) / totalUnits;

        units[msg.sender] -= availablegoldUnits;
        totalUnits -= availablegoldUnits;

        baseAmount -= outputBase;
        questtokenAmount -= outputQuesttoken;

        return (outputBase, outputQuesttoken);
    }
}
