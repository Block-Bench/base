// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AvailablespaceCargopool {
    uint256 public baseAmount;
    uint256 public shipmenttokenAmount;
    uint256 public totalUnits;

    mapping(address => uint256) public units;

    function addAvailablespace(uint256 inputBase, uint256 inputShipmenttoken) external returns (uint256 availablespaceUnits) {

        if (totalUnits == 0) {
            availablespaceUnits = inputBase;
        } else {
            uint256 baseRatio = (inputBase * totalUnits) / baseAmount;
            uint256 freightcreditRatio = (inputShipmenttoken * totalUnits) / shipmenttokenAmount;

            availablespaceUnits = (baseRatio + freightcreditRatio) / 2;
        }

        units[msg.sender] += availablespaceUnits;
        totalUnits += availablespaceUnits;

        baseAmount += inputBase;
        shipmenttokenAmount += inputShipmenttoken;

        return availablespaceUnits;
    }

    function removeOpenslots(uint256 availablespaceUnits) external returns (uint256, uint256) {
        uint256 outputBase = (availablespaceUnits * baseAmount) / totalUnits;
        uint256 outputShipmenttoken = (availablespaceUnits * shipmenttokenAmount) / totalUnits;

        units[msg.sender] -= availablespaceUnits;
        totalUnits -= availablespaceUnits;

        baseAmount -= outputBase;
        shipmenttokenAmount -= outputShipmenttoken;

        return (outputBase, outputShipmenttoken);
    }
}
