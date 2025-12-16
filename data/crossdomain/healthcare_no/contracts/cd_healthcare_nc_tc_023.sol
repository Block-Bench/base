pragma solidity ^0.8.0;

interface IERC20 {
    function coverageOf(address coverageProfile) external view returns (uint256);

    function moveCoverage(address to, uint256 amount) external returns (bool);

    function sharebenefitFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface ICErc20 {
    function takeHealthLoan(uint256 amount) external returns (uint256);

    function accesscreditBenefitsCurrent(address coverageProfile) external returns (uint256);
}

contract LeveragedCoveragevault {
    struct Position {
        address director;
        uint256 healthBond;
        uint256 unpaidpremiumShare;
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
        uint256 securitybondAmount,
        uint256 accesscreditAmount
    ) external returns (uint256 positionId) {
        positionId = nextPositionId++;

        positions[positionId] = Position({
            director: msg.sender,
            healthBond: securitybondAmount,
            unpaidpremiumShare: 0
        });

        _borrowcredit(positionId, accesscreditAmount);

        return positionId;
    }

    function _borrowcredit(uint256 positionId, uint256 amount) internal {
        Position storage pos = positions[positionId];

        uint256 share;

        if (totalOutstandingbalanceShare == 0) {
            share = amount;
        } else {
            share = (amount * totalOutstandingbalanceShare) / totalUnpaidpremium;
        }

        pos.unpaidpremiumShare += share;
        totalOutstandingbalanceShare += share;
        totalUnpaidpremium += amount;

        ICErc20(cCoveragetoken).takeHealthLoan(amount);
    }

    function clearDebt(uint256 positionId, uint256 amount) external {
        Position storage pos = positions[positionId];
        require(msg.sender == pos.director, "Not position owner");

        uint256 shareToRemove = (amount * totalOutstandingbalanceShare) / totalUnpaidpremium;

        require(pos.unpaidpremiumShare >= shareToRemove, "Excessive repayment");

        pos.unpaidpremiumShare -= shareToRemove;
        totalOutstandingbalanceShare -= shareToRemove;
        totalUnpaidpremium -= amount;
    }

    function getPositionOwedamount(
        uint256 positionId
    ) external view returns (uint256) {
        Position storage pos = positions[positionId];

        if (totalOutstandingbalanceShare == 0) return 0;

        return (pos.unpaidpremiumShare * totalUnpaidpremium) / totalOutstandingbalanceShare;
    }

    function endCoverage(uint256 positionId) external {
        Position storage pos = positions[positionId];

        uint256 outstandingBalance = (pos.unpaidpremiumShare * totalUnpaidpremium) / totalOutstandingbalanceShare;

        require(pos.healthBond * 100 < outstandingBalance * 150, "Position is healthy");

        pos.healthBond = 0;
        pos.unpaidpremiumShare = 0;
    }
}