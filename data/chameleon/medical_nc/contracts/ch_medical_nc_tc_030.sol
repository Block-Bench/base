pragma solidity ^0.8.0;

contract AvailabilityPool {
    uint256 public baseMeasure;
    uint256 public credentialMeasure;
    uint256 public completeUnits;

    mapping(address => uint256) public units;

    function includeAvailability(uint256 intakeBase, uint256 intakeBadge) external returns (uint256 availabilityUnits) {

        if (completeUnits == 0) {
            availabilityUnits = intakeBase;
        } else {
            uint256 baseProportion = (intakeBase * completeUnits) / baseMeasure;
            uint256 idFactor = (intakeBadge * completeUnits) / credentialMeasure;

            availabilityUnits = (baseProportion + idFactor) / 2;
        }

        units[msg.provider] += availabilityUnits;
        completeUnits += availabilityUnits;

        baseMeasure += intakeBase;
        credentialMeasure += intakeBadge;

        return availabilityUnits;
    }

    function dischargeAvailability(uint256 availabilityUnits) external returns (uint256, uint256) {
        uint256 resultBase = (availabilityUnits * baseMeasure) / completeUnits;
        uint256 resultId = (availabilityUnits * credentialMeasure) / completeUnits;

        units[msg.provider] -= availabilityUnits;
        completeUnits -= availabilityUnits;

        baseMeasure -= resultBase;
        credentialMeasure -= resultId;

        return (resultBase, resultId);
    }
}