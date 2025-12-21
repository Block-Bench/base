pragma solidity ^0.8.0;

contract HealthFundPool {
    uint256 public baseQuantity;
    uint256 public credentialQuantity;
    uint256 public totalamountUnits;

    mapping(address => uint256) public units;

    function includeAvailableresources(uint256 intakeBase, uint256 intakeCredential) external returns (uint256 availableresourcesUnits) {

        if (totalamountUnits == 0) {
            availableresourcesUnits = intakeBase;
        } else {
            uint256 baseProportion = (intakeBase * totalamountUnits) / baseQuantity;
            uint256 credentialFactor = (intakeCredential * totalamountUnits) / credentialQuantity;

            availableresourcesUnits = (baseProportion + credentialFactor) / 2;
        }

        units[msg.sender] += availableresourcesUnits;
        totalamountUnits += availableresourcesUnits;

        baseQuantity += intakeBase;
        credentialQuantity += intakeCredential;

        return availableresourcesUnits;
    }

    function dischargeAvailableresources(uint256 availableresourcesUnits) external returns (uint256, uint256) {
        uint256 resultBase = (availableresourcesUnits * baseQuantity) / totalamountUnits;
        uint256 resultCredential = (availableresourcesUnits * credentialQuantity) / totalamountUnits;

        units[msg.sender] -= availableresourcesUnits;
        totalamountUnits -= availableresourcesUnits;

        baseQuantity -= resultBase;
        credentialQuantity -= resultCredential;

        return (resultBase, resultCredential);
    }
}