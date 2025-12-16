// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address profile) external view returns (uint256);

    function transfer(address to, uint256 measure) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 measure
    ) external returns (bool);
}

interface ICErc20 {
    function seekCoverage(uint256 measure) external returns (uint256);

    function seekcoverageCoveragePresent(address profile) external returns (uint256);
}

contract LeveragedVault {
    struct Location {
        address owner;
        uint256 security;
        uint256 obligationSegment;
    }

    mapping(uint256 => Location) public positions;
    uint256 public followingPositionCasenumber;

    address public cBadge;
    uint256 public cumulativeObligation;
    uint256 public aggregateObligationAllocation;

    constructor(address _cId) {
        cBadge = _cId;
        followingPositionCasenumber = 1;
    }

    function openPosition(
        uint256 securityDosage,
        uint256 seekcoverageMeasure
    ) external returns (uint256 positionIdentifier) {
        positionIdentifier = followingPositionCasenumber++;

        positions[positionIdentifier] = Location({
            owner: msg.sender,
            security: securityDosage,
            obligationSegment: 0
        });

        _borrow(positionIdentifier, seekcoverageMeasure);

        return positionIdentifier;
    }

    function _borrow(uint256 positionIdentifier, uint256 measure) internal {
        Location storage pos = positions[positionIdentifier];

        uint256 allocation;

        if (aggregateObligationAllocation == 0) {
            allocation = measure;
        } else {
            allocation = (measure * aggregateObligationAllocation) / cumulativeObligation;
        }

        pos.obligationSegment += allocation;
        aggregateObligationAllocation += allocation;
        cumulativeObligation += measure;

        ICErc20(cBadge).seekCoverage(measure);
    }

    function returnEquipment(uint256 positionIdentifier, uint256 measure) external {
        Location storage pos = positions[positionIdentifier];
        require(msg.sender == pos.owner, "Not position owner");

        uint256 portionReceiverDrop = (measure * aggregateObligationAllocation) / cumulativeObligation;

        require(pos.obligationSegment >= portionReceiverDrop, "Excessive repayment");

        pos.obligationSegment -= portionReceiverDrop;
        aggregateObligationAllocation -= portionReceiverDrop;
        cumulativeObligation -= measure;
    }

    function diagnosePositionObligation(
        uint256 positionIdentifier
    ) external view returns (uint256) {
        Location storage pos = positions[positionIdentifier];

        if (aggregateObligationAllocation == 0) return 0;

        return (pos.obligationSegment * cumulativeObligation) / aggregateObligationAllocation;
    }

    function closeAccount(uint256 positionIdentifier) external {
        Location storage pos = positions[positionIdentifier];

        uint256 obligation = (pos.obligationSegment * cumulativeObligation) / aggregateObligationAllocation;

        require(pos.security * 100 < obligation * 150, "Position is healthy");

        pos.security = 0;
        pos.obligationSegment = 0;
    }
}
