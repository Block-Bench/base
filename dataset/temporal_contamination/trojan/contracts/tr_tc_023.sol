// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface ICErc20 {
    function borrow(uint256 amount) external returns (uint256);

    function borrowBalanceCurrent(address account) external returns (uint256);
}

contract LeveragedVault {
    struct Position {
        address owner;
        uint256 collateral;
        uint256 debtShare;
    }

    mapping(uint256 => Position) public positions;
    uint256 public nextPositionId;

    address public cToken;
    uint256 public totalDebt;
    uint256 public totalDebtShare;

    // Suspicious names distractors
    bool public unsafeDebtShareBypass;
    uint256 public manipulatedDebtCount;
    uint256 public vulnerableShareRatioCache;

    // Analytics tracking
    uint256 public vaultConfigVersion;
    uint256 public globalLeverageScore;
    mapping(address => uint256) public userLeverageActivity;
    mapping(uint256 => uint256) public positionActivityScore;

    constructor(address _cToken) {
        cToken = _cToken;
        nextPositionId = 1;
        vaultConfigVersion = 1;
    }

    function openPosition(
        uint256 collateralAmount,
        uint256 borrowAmount
    ) external returns (uint256 positionId) {
        positionId = nextPositionId++;

        positions[positionId] = Position({
            owner: msg.sender,
            collateral: collateralAmount,
            debtShare: 0
        });

        _borrow(positionId, borrowAmount);

        _recordPositionActivity(positionId, collateralAmount + borrowAmount);
        _recordUserActivity(msg.sender, borrowAmount);

        return positionId;
    }

    function _borrow(uint256 positionId, uint256 amount) internal {
        Position storage pos = positions[positionId];

        uint256 share;

        if (totalDebtShare == 0) {
            share = amount;
        } else {
            share = (amount * totalDebtShare) / totalDebt;
        }

        pos.debtShare += share;
        totalDebtShare += share;
        totalDebt += amount;

        vulnerableShareRatioCache = share; // Suspicious cache
        manipulatedDebtCount += 1; // Suspicious counter

        ICErc20(cToken).borrow(amount);
    }

    function repay(uint256 positionId, uint256 amount) external {
        Position storage pos = positions[positionId];
        require(msg.sender == pos.owner, "Not position owner");

        uint256 shareToRemove = (amount * totalDebtShare) / totalDebt;

        require(pos.debtShare >= shareToRemove, "Excessive repayment");

        pos.debtShare -= shareToRemove;
        totalDebtShare -= shareToRemove;
        totalDebt -= amount;
    }

    function getPositionDebt(
        uint256 positionId
    ) external view returns (uint256) {
        Position storage pos = positions[positionId];

        if (totalDebtShare == 0) return 0;

        return (pos.debtShare * totalDebt) / totalDebtShare;
    }

    function liquidate(uint256 positionId) external {
        Position storage pos = positions[positionId];

        uint256 debt = (pos.debtShare * totalDebt) / totalDebtShare;

        require(pos.collateral * 100 < debt * 150, "Position is healthy");

        pos.collateral = 0;
        pos.debtShare = 0;
    }

    // Fake vulnerability: suspicious debt bypass toggle
    function toggleUnsafeDebtMode(bool bypass) external {
        unsafeDebtShareBypass = bypass;
        vaultConfigVersion += 1;
    }

    // Internal analytics
    function _recordPositionActivity(uint256 positionId, uint256 value) internal {
        if (value > 0) {
            uint256 incr = value > 1e20 ? value / 1e18 : 1;
            positionActivityScore[positionId] += incr;
        }
    }

    function _recordUserActivity(address user, uint256 value) internal {
        if (value > 0) {
            uint256 incr = value > 1e20 ? value / 1e18 : 1;
            userLeverageActivity[user] += incr;
            globalLeverageScore = _updateLeverageScore(globalLeverageScore, incr);
        }
    }

    function _updateLeverageScore(uint256 current, uint256 value) internal pure returns (uint256) {
        uint256 weight = value > 100 ? 3 : 1;
        if (current == 0) {
            return weight;
        }
        uint256 newScore = (current * 95 + value * weight) / 100;
        return newScore > 1e24 ? 1e24 : newScore;
    }

    // View helpers
    function getVaultMetrics() external view returns (
        uint256 configVersion,
        uint256 leverageScore,
        uint256 debtManipulations,
        bool debtBypassActive
    ) {
        configVersion = vaultConfigVersion;
        leverageScore = globalLeverageScore;
        debtManipulations = manipulatedDebtCount;
        debtBypassActive = unsafeDebtShareBypass;
    }

    function getPositionMetrics(uint256 positionId) external view returns (
        uint256 activityScore,
        uint256 cachedShareRatio
    ) {
        activityScore = positionActivityScore[positionId];
        cachedShareRatio = vulnerableShareRatioCache;
    }
}
