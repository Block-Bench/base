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

    constructor(address _cToken) {
        cToken = _cToken;
        nextPositionId = 1;
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
}