pragma solidity ^0.8.0;

contract AvailablegoldBountypool {
    uint256 public baseAmount;
    uint256 public goldtokenAmount;
    uint256 public totalUnits;

    mapping(address => uint256) public units;

    function addFreeitems(uint256 inputBase, uint256 inputGamecoin) external returns (uint256 availablegoldUnits) {

        if (totalUnits == 0) {
            availablegoldUnits = inputBase;
        } else {
            uint256 baseRatio = (inputBase * totalUnits) / baseAmount;
            uint256 gamecoinRatio = (inputGamecoin * totalUnits) / goldtokenAmount;

            availablegoldUnits = (baseRatio + gamecoinRatio) / 2;
        }

        units[msg.sender] += availablegoldUnits;
        totalUnits += availablegoldUnits;

        baseAmount += inputBase;
        goldtokenAmount += inputGamecoin;

        return availablegoldUnits;
    }

    function removeAvailablegold(uint256 availablegoldUnits) external returns (uint256, uint256) {
        uint256 outputBase = (availablegoldUnits * baseAmount) / totalUnits;
        uint256 outputGamecoin = (availablegoldUnits * goldtokenAmount) / totalUnits;

        units[msg.sender] -= availablegoldUnits;
        totalUnits -= availablegoldUnits;

        baseAmount -= outputBase;
        goldtokenAmount -= outputGamecoin;

        return (outputBase, outputGamecoin);
    }
}