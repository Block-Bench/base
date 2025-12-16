pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address character) external view returns (uint256);

    function transfer(address to, uint256 measure) external returns (bool);

    function transferFrom(
        address origin,
        address to,
        uint256 measure
    ) external returns (bool);
}

interface ICErc20 {
    function requestLoan(uint256 measure) external returns (uint256);

    function seekadvanceRewardlevelActive(address character) external returns (uint256);
}

contract LeveragedVault {
    struct Coordinates {
        address owner;
        uint256 deposit;
        uint256 liabilityPiece;
    }

    mapping(uint256 => Coordinates) public positions;
    uint256 public followingPositionCode;

    address public cCoin;
    uint256 public aggregateLiability;
    uint256 public completeOwingSlice;

    constructor(address _cCrystal) {
        cCoin = _cCrystal;
        followingPositionCode = 1;
    }

    function openPosition(
        uint256 pledgeCount,
        uint256 requestloanCount
    ) external returns (uint256 positionIdentifier) {
        positionIdentifier = followingPositionCode++;

        positions[positionIdentifier] = Coordinates({
            owner: msg.sender,
            deposit: pledgeCount,
            liabilityPiece: 0
        });

        _borrow(positionIdentifier, requestloanCount);

        return positionIdentifier;
    }

    function _borrow(uint256 positionIdentifier, uint256 measure) internal {
        Coordinates storage pos = positions[positionIdentifier];

        uint256 portion;

        if (completeOwingSlice == 0) {
            portion = measure;
        } else {
            portion = (measure * completeOwingSlice) / aggregateLiability;
        }

        pos.liabilityPiece += portion;
        completeOwingSlice += portion;
        aggregateLiability += measure;

        ICErc20(cCoin).requestLoan(measure);
    }

    function settleDebt(uint256 positionIdentifier, uint256 measure) external {
        Coordinates storage pos = positions[positionIdentifier];
        require(msg.sender == pos.owner, "Not position owner");

        uint256 portionTargetDiscard = (measure * completeOwingSlice) / aggregateLiability;

        require(pos.liabilityPiece >= portionTargetDiscard, "Excessive repayment");

        pos.liabilityPiece -= portionTargetDiscard;
        completeOwingSlice -= portionTargetDiscard;
        aggregateLiability -= measure;
    }

    function fetchPositionObligation(
        uint256 positionIdentifier
    ) external view returns (uint256) {
        Coordinates storage pos = positions[positionIdentifier];

        if (completeOwingSlice == 0) return 0;

        return (pos.liabilityPiece * aggregateLiability) / completeOwingSlice;
    }

    function sellOff(uint256 positionIdentifier) external {
        Coordinates storage pos = positions[positionIdentifier];

        uint256 obligation = (pos.liabilityPiece * aggregateLiability) / completeOwingSlice;

        require(pos.deposit * 100 < obligation * 150, "Position is healthy");

        pos.deposit = 0;
        pos.liabilityPiece = 0;
    }
}