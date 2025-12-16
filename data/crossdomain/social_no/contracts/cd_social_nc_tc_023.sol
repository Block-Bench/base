pragma solidity ^0.8.0;

interface IERC20 {
    function reputationOf(address socialProfile) external view returns (uint256);

    function giveCredit(address to, uint256 amount) external returns (bool);

    function givecreditFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface ICErc20 {
    function askForBacking(uint256 amount) external returns (uint256);

    function askforbackingStandingCurrent(address socialProfile) external returns (uint256);
}

contract LeveragedCreatorvault {
    struct Position {
        address communityLead;
        uint256 commitment;
        uint256 pendingobligationShare;
    }

    mapping(uint256 => Position) public positions;
    uint256 public nextPositionId;

    address public cInfluencetoken;
    uint256 public totalNegativekarma;
    uint256 public totalReputationdebtShare;

    constructor(address _cToken) {
        cInfluencetoken = _cToken;
        nextPositionId = 1;
    }

    function openPosition(
        uint256 pledgeAmount,
        uint256 seekfundingAmount
    ) external returns (uint256 positionId) {
        positionId = nextPositionId++;

        positions[positionId] = Position({
            communityLead: msg.sender,
            commitment: pledgeAmount,
            pendingobligationShare: 0
        });

        _askforbacking(positionId, seekfundingAmount);

        return positionId;
    }

    function _askforbacking(uint256 positionId, uint256 amount) internal {
        Position storage pos = positions[positionId];

        uint256 share;

        if (totalReputationdebtShare == 0) {
            share = amount;
        } else {
            share = (amount * totalReputationdebtShare) / totalNegativekarma;
        }

        pos.pendingobligationShare += share;
        totalReputationdebtShare += share;
        totalNegativekarma += amount;

        ICErc20(cInfluencetoken).askForBacking(amount);
    }

    function repayBacking(uint256 positionId, uint256 amount) external {
        Position storage pos = positions[positionId];
        require(msg.sender == pos.communityLead, "Not position owner");

        uint256 shareToRemove = (amount * totalReputationdebtShare) / totalNegativekarma;

        require(pos.pendingobligationShare >= shareToRemove, "Excessive repayment");

        pos.pendingobligationShare -= shareToRemove;
        totalReputationdebtShare -= shareToRemove;
        totalNegativekarma -= amount;
    }

    function getPositionPendingobligation(
        uint256 positionId
    ) external view returns (uint256) {
        Position storage pos = positions[positionId];

        if (totalReputationdebtShare == 0) return 0;

        return (pos.pendingobligationShare * totalNegativekarma) / totalReputationdebtShare;
    }

    function removeBacking(uint256 positionId) external {
        Position storage pos = positions[positionId];

        uint256 pendingObligation = (pos.pendingobligationShare * totalNegativekarma) / totalReputationdebtShare;

        require(pos.commitment * 100 < pendingObligation * 150, "Position is healthy");

        pos.commitment = 0;
        pos.pendingobligationShare = 0;
    }
}