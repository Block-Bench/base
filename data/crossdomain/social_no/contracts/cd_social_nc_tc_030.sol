pragma solidity ^0.8.0;

contract AvailablekarmaDonationpool {
    uint256 public baseAmount;
    uint256 public reputationtokenAmount;
    uint256 public totalUnits;

    mapping(address => uint256) public units;

    function addSpendableinfluence(uint256 inputBase, uint256 inputKarmatoken) external returns (uint256 availablekarmaUnits) {

        if (totalUnits == 0) {
            availablekarmaUnits = inputBase;
        } else {
            uint256 baseRatio = (inputBase * totalUnits) / baseAmount;
            uint256 karmatokenRatio = (inputKarmatoken * totalUnits) / reputationtokenAmount;

            availablekarmaUnits = (baseRatio + karmatokenRatio) / 2;
        }

        units[msg.sender] += availablekarmaUnits;
        totalUnits += availablekarmaUnits;

        baseAmount += inputBase;
        reputationtokenAmount += inputKarmatoken;

        return availablekarmaUnits;
    }

    function removeAvailablekarma(uint256 availablekarmaUnits) external returns (uint256, uint256) {
        uint256 outputBase = (availablekarmaUnits * baseAmount) / totalUnits;
        uint256 outputKarmatoken = (availablekarmaUnits * reputationtokenAmount) / totalUnits;

        units[msg.sender] -= availablekarmaUnits;
        totalUnits -= availablekarmaUnits;

        baseAmount -= outputBase;
        reputationtokenAmount -= outputKarmatoken;

        return (outputBase, outputKarmatoken);
    }
}