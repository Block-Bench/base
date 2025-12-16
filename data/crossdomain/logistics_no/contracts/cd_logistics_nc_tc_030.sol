pragma solidity ^0.8.0;

contract AvailablespaceFreightpool {
    uint256 public baseAmount;
    uint256 public inventorytokenAmount;
    uint256 public totalUnits;

    mapping(address => uint256) public units;

    function addFreecapacity(uint256 inputBase, uint256 inputCargotoken) external returns (uint256 availablespaceUnits) {

        if (totalUnits == 0) {
            availablespaceUnits = inputBase;
        } else {
            uint256 baseRatio = (inputBase * totalUnits) / baseAmount;
            uint256 cargotokenRatio = (inputCargotoken * totalUnits) / inventorytokenAmount;

            availablespaceUnits = (baseRatio + cargotokenRatio) / 2;
        }

        units[msg.sender] += availablespaceUnits;
        totalUnits += availablespaceUnits;

        baseAmount += inputBase;
        inventorytokenAmount += inputCargotoken;

        return availablespaceUnits;
    }

    function removeAvailablespace(uint256 availablespaceUnits) external returns (uint256, uint256) {
        uint256 outputBase = (availablespaceUnits * baseAmount) / totalUnits;
        uint256 outputCargotoken = (availablespaceUnits * inventorytokenAmount) / totalUnits;

        units[msg.sender] -= availablespaceUnits;
        totalUnits -= availablespaceUnits;

        baseAmount -= outputBase;
        inventorytokenAmount -= outputCargotoken;

        return (outputBase, outputCargotoken);
    }
}