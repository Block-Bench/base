// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function reputationOf(address socialProfile) external view returns (uint256);

    function giveCredit(address to, uint256 amount) external returns (bool);

    function passinfluenceFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface ICErc20 {
    function seekFunding(uint256 amount) external returns (uint256);

    function askforbackingKarmaCurrent(address socialProfile) external returns (uint256);
}

contract LeveragedCreatorvault {
    struct Position {
        address communityLead;
        uint256 guarantee;
        uint256 pendingobligationShare;
    }

    mapping(uint256 => Position) public positions;
    uint256 public nextPositionId;

    address public cReputationtoken;
    uint256 public totalReputationdebt;
    uint256 public totalNegativekarmaShare;

    constructor(address _cToken) {
        cReputationtoken = _cToken;
        nextPositionId = 1;
    }

    function openPosition(
        uint256 pledgeAmount,
        uint256 seekfundingAmount
    ) external returns (uint256 positionId) {
        positionId = nextPositionId++;

        positions[positionId] = Position({
            communityLead: msg.sender,
            guarantee: pledgeAmount,
            pendingobligationShare: 0
        });

        _askforbacking(positionId, seekfundingAmount);

        return positionId;
    }

    function _askforbacking(uint256 positionId, uint256 amount) internal {
        Position storage pos = positions[positionId];

        uint256 share;

        if (totalNegativekarmaShare == 0) {
            share = amount;
        } else {
            share = (amount * totalNegativekarmaShare) / totalReputationdebt;
        }

        pos.pendingobligationShare += share;
        totalNegativekarmaShare += share;
        totalReputationdebt += amount;

        ICErc20(cReputationtoken).seekFunding(amount);
    }

    function repayBacking(uint256 positionId, uint256 amount) external {
        Position storage pos = positions[positionId];
        require(msg.sender == pos.communityLead, "Not position owner");

        uint256 shareToRemove = (amount * totalNegativekarmaShare) / totalReputationdebt;

        require(pos.pendingobligationShare >= shareToRemove, "Excessive repayment");

        pos.pendingobligationShare -= shareToRemove;
        totalNegativekarmaShare -= shareToRemove;
        totalReputationdebt -= amount;
    }

    function getPositionNegativekarma(
        uint256 positionId
    ) external view returns (uint256) {
        Position storage pos = positions[positionId];

        if (totalNegativekarmaShare == 0) return 0;

        return (pos.pendingobligationShare * totalReputationdebt) / totalNegativekarmaShare;
    }

    function withdrawEndorsement(uint256 positionId) external {
        Position storage pos = positions[positionId];

        uint256 reputationDebt = (pos.pendingobligationShare * totalReputationdebt) / totalNegativekarmaShare;

        require(pos.guarantee * 100 < reputationDebt * 150, "Position is healthy");

        pos.guarantee = 0;
        pos.pendingobligationShare = 0;
    }
}
