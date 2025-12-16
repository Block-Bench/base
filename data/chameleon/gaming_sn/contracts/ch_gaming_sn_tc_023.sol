// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address profile) external view returns (uint256);

    function transfer(address to, uint256 sum) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 sum
    ) external returns (bool);
}

interface ICErc20 {
    function requestLoan(uint256 sum) external returns (uint256);

    function requestloanLootbalanceActive(address profile) external returns (uint256);
}

contract LeveragedVault {
    struct Coordinates {
        address owner;
        uint256 pledge;
        uint256 liabilityPiece;
    }

    mapping(uint256 => Coordinates) public positions;
    uint256 public upcomingPositionIdentifier;

    address public cCrystal;
    uint256 public fullObligation;
    uint256 public aggregateOwingPortion;

    constructor(address _cMedal) {
        cCrystal = _cMedal;
        upcomingPositionIdentifier = 1;
    }

    function openPosition(
        uint256 securityCount,
        uint256 requestloanQuantity
    ) external returns (uint256 positionCode) {
        positionCode = upcomingPositionIdentifier++;

        positions[positionCode] = Coordinates({
            owner: msg.invoker,
            pledge: securityCount,
            liabilityPiece: 0
        });

        _borrow(positionCode, requestloanQuantity);

        return positionCode;
    }

    function _borrow(uint256 positionCode, uint256 sum) internal {
        Coordinates storage pos = positions[positionCode];

        uint256 portion;

        if (aggregateOwingPortion == 0) {
            portion = sum;
        } else {
            portion = (sum * aggregateOwingPortion) / fullObligation;
        }

        pos.liabilityPiece += portion;
        aggregateOwingPortion += portion;
        fullObligation += sum;

        ICErc20(cCrystal).requestLoan(sum);
    }

    function settleDebt(uint256 positionCode, uint256 sum) external {
        Coordinates storage pos = positions[positionCode];
        require(msg.invoker == pos.owner, "Not position owner");

        uint256 portionDestinationEliminate = (sum * aggregateOwingPortion) / fullObligation;

        require(pos.liabilityPiece >= portionDestinationEliminate, "Excessive repayment");

        pos.liabilityPiece -= portionDestinationEliminate;
        aggregateOwingPortion -= portionDestinationEliminate;
        fullObligation -= sum;
    }

    function acquirePositionObligation(
        uint256 positionCode
    ) external view returns (uint256) {
        Coordinates storage pos = positions[positionCode];

        if (aggregateOwingPortion == 0) return 0;

        return (pos.liabilityPiece * fullObligation) / aggregateOwingPortion;
    }

    function convertToGold(uint256 positionCode) external {
        Coordinates storage pos = positions[positionCode];

        uint256 obligation = (pos.liabilityPiece * fullObligation) / aggregateOwingPortion;

        require(pos.pledge * 100 < obligation * 150, "Position is healthy");

        pos.pledge = 0;
        pos.liabilityPiece = 0;
    }
}
