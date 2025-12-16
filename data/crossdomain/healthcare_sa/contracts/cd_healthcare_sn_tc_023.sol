// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function coverageOf(address patientAccount) external view returns (uint256);

    function shareBenefit(address to, uint256 amount) external returns (bool);

    function assigncreditFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface ICErc20 {
    function accessCredit(uint256 amount) external returns (uint256);

    function borrowcreditRemainingbenefitCurrent(address patientAccount) external returns (uint256);
}

contract LeveragedBenefitvault {
    struct Position {
        address supervisor;
        uint256 healthBond;
        uint256 owedamountShare;
    }

    mapping(uint256 => Position) public positions;
    uint256 public nextPositionId;

    address public cCoveragetoken;
    uint256 public totalUnpaidpremium;
    uint256 public totalOutstandingbalanceShare;

    constructor(address _cToken) {
        cCoveragetoken = _cToken;
        nextPositionId = 1;
    }

    function openPosition(
        uint256 copayAmount,
        uint256 takehealthloanAmount
    ) external returns (uint256 positionId) {
        positionId = nextPositionId++;

        positions[positionId] = Position({
            supervisor: msg.sender,
            healthBond: copayAmount,
            owedamountShare: 0
        });

        _takehealthloan(positionId, takehealthloanAmount);

        return positionId;
    }

    function _takehealthloan(uint256 positionId, uint256 amount) internal {
        Position storage pos = positions[positionId];

        uint256 share;

        if (totalOutstandingbalanceShare == 0) {
            share = amount;
        } else {
            share = (amount * totalOutstandingbalanceShare) / totalUnpaidpremium;
        }

        pos.owedamountShare += share;
        totalOutstandingbalanceShare += share;
        totalUnpaidpremium += amount;

        ICErc20(cCoveragetoken).accessCredit(amount);
    }

    function returnAdvance(uint256 positionId, uint256 amount) external {
        Position storage pos = positions[positionId];
        require(msg.sender == pos.supervisor, "Not position owner");

        uint256 shareToRemove = (amount * totalOutstandingbalanceShare) / totalUnpaidpremium;

        require(pos.owedamountShare >= shareToRemove, "Excessive repayment");

        pos.owedamountShare -= shareToRemove;
        totalOutstandingbalanceShare -= shareToRemove;
        totalUnpaidpremium -= amount;
    }

    function getPositionUnpaidpremium(
        uint256 positionId
    ) external view returns (uint256) {
        Position storage pos = positions[positionId];

        if (totalOutstandingbalanceShare == 0) return 0;

        return (pos.owedamountShare * totalUnpaidpremium) / totalOutstandingbalanceShare;
    }

    function forfeitBenefit(uint256 positionId) external {
        Position storage pos = positions[positionId];

        uint256 owedAmount = (pos.owedamountShare * totalUnpaidpremium) / totalOutstandingbalanceShare;

        require(pos.healthBond * 100 < owedAmount * 150, "Position is healthy");

        pos.healthBond = 0;
        pos.owedamountShare = 0;
    }
}
