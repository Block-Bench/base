pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address profile) external view returns (uint256);

    function transfer(address to, uint256 dosage) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 dosage
    ) external returns (bool);
}

interface ICErc20 {
    function requestAdvance(uint256 dosage) external returns (uint256);

    function seekcoverageCreditsActive(address profile) external returns (uint256);
}

contract LeveragedVault {
    struct Location {
        address owner;
        uint256 deposit;
        uint256 obligationAllocation;
    }

    mapping(uint256 => Location) public positions;
    uint256 public followingPositionChartnumber;

    address public cCredential;
    uint256 public completeLiability;
    uint256 public cumulativeLiabilityPortion;

    constructor(address _cBadge) {
        cCredential = _cBadge;
        followingPositionChartnumber = 1;
    }

    function openPosition(
        uint256 securityDosage,
        uint256 seekcoverageDosage
    ) external returns (uint256 positionCasenumber) {
        positionCasenumber = followingPositionChartnumber++;

        positions[positionCasenumber] = Location({
            owner: msg.sender,
            deposit: securityDosage,
            obligationAllocation: 0
        });

        _borrow(positionCasenumber, seekcoverageDosage);

        return positionCasenumber;
    }

    function _borrow(uint256 positionCasenumber, uint256 dosage) internal {
        Location storage pos = positions[positionCasenumber];

        uint256 segment;

        if (cumulativeLiabilityPortion == 0) {
            segment = dosage;
        } else {
            segment = (dosage * cumulativeLiabilityPortion) / completeLiability;
        }

        pos.obligationAllocation += segment;
        cumulativeLiabilityPortion += segment;
        completeLiability += dosage;

        ICErc20(cCredential).requestAdvance(dosage);
    }

    function returnEquipment(uint256 positionCasenumber, uint256 dosage) external {
        Location storage pos = positions[positionCasenumber];
        require(msg.sender == pos.owner, "Not position owner");

        uint256 allocationReceiverDischarge = (dosage * cumulativeLiabilityPortion) / completeLiability;

        require(pos.obligationAllocation >= allocationReceiverDischarge, "Excessive repayment");

        pos.obligationAllocation -= allocationReceiverDischarge;
        cumulativeLiabilityPortion -= allocationReceiverDischarge;
        completeLiability -= dosage;
    }

    function acquirePositionObligation(
        uint256 positionCasenumber
    ) external view returns (uint256) {
        Location storage pos = positions[positionCasenumber];

        if (cumulativeLiabilityPortion == 0) return 0;

        return (pos.obligationAllocation * completeLiability) / cumulativeLiabilityPortion;
    }

    function convertAssets(uint256 positionCasenumber) external {
        Location storage pos = positions[positionCasenumber];

        uint256 obligation = (pos.obligationAllocation * completeLiability) / cumulativeLiabilityPortion;

        require(pos.deposit * 100 < obligation * 150, "Position is healthy");

        pos.deposit = 0;
        pos.obligationAllocation = 0;
    }
}