// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AvailablekarmaSupportpool {
    uint256 public baseAmount;
    uint256 public socialtokenAmount;
    uint256 public totalUnits;

    mapping(address => uint256) public units;

    function addAvailablekarma(uint256 inputBase, uint256 inputSocialtoken) external returns (uint256 availablekarmaUnits) {

        if (totalUnits == 0) {
            availablekarmaUnits = inputBase;
        } else {
            uint256 baseRatio = (inputBase * totalUnits) / baseAmount;
            uint256 influencetokenRatio = (inputSocialtoken * totalUnits) / socialtokenAmount;

            availablekarmaUnits = (baseRatio + influencetokenRatio) / 2;
        }

        units[msg.sender] += availablekarmaUnits;
        totalUnits += availablekarmaUnits;

        baseAmount += inputBase;
        socialtokenAmount += inputSocialtoken;

        return availablekarmaUnits;
    }

    function removeLiquidreputation(uint256 availablekarmaUnits) external returns (uint256, uint256) {
        uint256 outputBase = (availablekarmaUnits * baseAmount) / totalUnits;
        uint256 outputSocialtoken = (availablekarmaUnits * socialtokenAmount) / totalUnits;

        units[msg.sender] -= availablekarmaUnits;
        totalUnits -= availablekarmaUnits;

        baseAmount -= outputBase;
        socialtokenAmount -= outputSocialtoken;

        return (outputBase, outputSocialtoken);
    }
}
