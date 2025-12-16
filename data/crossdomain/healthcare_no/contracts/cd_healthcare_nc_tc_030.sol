pragma solidity ^0.8.0;

contract AvailablebenefitClaimpool {
    uint256 public baseAmount;
    uint256 public coveragetokenAmount;
    uint256 public totalUnits;

    mapping(address => uint256) public units;

    function addAccessiblecoverage(uint256 inputBase, uint256 inputHealthtoken) external returns (uint256 availablebenefitUnits) {

        if (totalUnits == 0) {
            availablebenefitUnits = inputBase;
        } else {
            uint256 baseRatio = (inputBase * totalUnits) / baseAmount;
            uint256 healthtokenRatio = (inputHealthtoken * totalUnits) / coveragetokenAmount;

            availablebenefitUnits = (baseRatio + healthtokenRatio) / 2;
        }

        units[msg.sender] += availablebenefitUnits;
        totalUnits += availablebenefitUnits;

        baseAmount += inputBase;
        coveragetokenAmount += inputHealthtoken;

        return availablebenefitUnits;
    }

    function removeAvailablebenefit(uint256 availablebenefitUnits) external returns (uint256, uint256) {
        uint256 outputBase = (availablebenefitUnits * baseAmount) / totalUnits;
        uint256 outputHealthtoken = (availablebenefitUnits * coveragetokenAmount) / totalUnits;

        units[msg.sender] -= availablebenefitUnits;
        totalUnits -= availablebenefitUnits;

        baseAmount -= outputBase;
        coveragetokenAmount -= outputHealthtoken;

        return (outputBase, outputHealthtoken);
    }
}