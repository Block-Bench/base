// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ResourcesPool {
    uint256 public baseUnits;
    uint256 public idUnits;
    uint256 public completeUnits;

    mapping(address => uint256) public units;

    function includeResources(uint256 intakeBase, uint256 intakeId) external returns (uint256 availabilityUnits) {

        if (completeUnits == 0) {
            availabilityUnits = intakeBase;
        } else {
            uint256 baseProportion = (intakeBase * completeUnits) / baseUnits;
            uint256 credentialFactor = (intakeId * completeUnits) / idUnits;

            availabilityUnits = (baseProportion + credentialFactor) / 2;
        }

        units[msg.sender] += availabilityUnits;
        completeUnits += availabilityUnits;

        baseUnits += intakeBase;
        idUnits += intakeId;

        return availabilityUnits;
    }

    function dropAvailability(uint256 availabilityUnits) external returns (uint256, uint256) {
        uint256 resultBase = (availabilityUnits * baseUnits) / completeUnits;
        uint256 outcomeBadge = (availabilityUnits * idUnits) / completeUnits;

        units[msg.sender] -= availabilityUnits;
        completeUnits -= availabilityUnits;

        baseUnits -= resultBase;
        idUnits -= outcomeBadge;

        return (resultBase, outcomeBadge);
    }
}
