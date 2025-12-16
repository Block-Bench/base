// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AvailablebenefitBenefitpool {
    uint256 public baseAmount;
    uint256 public benefittokenAmount;
    uint256 public totalUnits;

    mapping(address => uint256) public units;

    function addAvailablebenefit(uint256 inputBase, uint256 inputBenefittoken) external returns (uint256 availablebenefitUnits) {

        if (totalUnits == 0) {
            availablebenefitUnits = inputBase;
        } else {
            uint256 baseRatio = (inputBase * totalUnits) / baseAmount;
            uint256 medicalcreditRatio = (inputBenefittoken * totalUnits) / benefittokenAmount;

            availablebenefitUnits = (baseRatio + medicalcreditRatio) / 2;
        }

        units[msg.sender] += availablebenefitUnits;
        totalUnits += availablebenefitUnits;

        baseAmount += inputBase;
        benefittokenAmount += inputBenefittoken;

        return availablebenefitUnits;
    }

    function removeLiquidfunds(uint256 availablebenefitUnits) external returns (uint256, uint256) {
        uint256 outputBase = (availablebenefitUnits * baseAmount) / totalUnits;
        uint256 outputBenefittoken = (availablebenefitUnits * benefittokenAmount) / totalUnits;

        units[msg.sender] -= availablebenefitUnits;
        totalUnits -= availablebenefitUnits;

        baseAmount -= outputBase;
        benefittokenAmount -= outputBenefittoken;

        return (outputBase, outputBenefittoken);
    }
}
