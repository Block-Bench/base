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
            debtShare: borrowAmount
        });

        totalDebtShare += borrowAmount;

        ICErc20(cToken).borrow(borrowAmount);

        return positionId;
    }

    function repay(uint256 positionId, uint256 amount) external {
        Position storage pos = positions[positionId];
        require(msg.sender == pos.owner, "Not position owner");

        require(pos.debtShare >= amount, "Excessive repayment");

        pos.debtShare -= amount;
        totalDebtShare -= amount;
    }

    function getPositionDebt(
        uint256 positionId
    ) external view returns (uint256) {
        Position storage pos = positions[positionId];
        return pos.debtShare;
    }

    function liquidate(uint256 positionId) external {
        Position storage pos = positions[positionId];

        require(pos.collateral * 100 < pos.debtShare * 150, "Position is healthy");

        pos.collateral = 0;
        pos.debtShare = 0;
    }
}
