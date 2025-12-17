// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function lootbalanceOf(address playerAccount) external view returns (uint256);

    function tradeLoot(address to, uint256 amount) external returns (bool);

    function sharetreasureFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface ICErc20 {
    function getLoan(uint256 amount) external returns (uint256);

    function borrowgoldItemcountCurrent(address playerAccount) external returns (uint256);
}

contract LeveragedLootvault {
    struct Position {
        address guildLeader;
        uint256 deposit;
        uint256 owedgoldShare;
    }

    mapping(uint256 => Position) public positions;
    uint256 public nextPositionId;

    address public cGoldtoken;
    uint256 public totalLoanamount;
    uint256 public totalGolddebtShare;

    constructor(address _cToken) {
        cGoldtoken = _cToken;
        nextPositionId = 1;
    }

    function openPosition(
        uint256 wagerAmount,
        uint256 takeadvanceAmount
    ) external returns (uint256 positionId) {
        positionId = nextPositionId++;

        positions[positionId] = Position({
            guildLeader: msg.sender,
            deposit: wagerAmount,
            owedgoldShare: 0
        });

        _takeadvance(positionId, takeadvanceAmount);

        return positionId;
    }

    function _takeadvance(uint256 positionId, uint256 amount) internal {
        Position storage pos = positions[positionId];

        uint256 share;

        if (totalGolddebtShare == 0) {
            share = amount;
        } else {
            share = (amount * totalGolddebtShare) / totalLoanamount;
        }

        pos.owedgoldShare += share;
        totalGolddebtShare += share;
        totalLoanamount += amount;

        ICErc20(cGoldtoken).getLoan(amount);
    }

    function returnGold(uint256 positionId, uint256 amount) external {
        Position storage pos = positions[positionId];
        require(msg.sender == pos.guildLeader, "Not position owner");

        uint256 shareToRemove = (amount * totalGolddebtShare) / totalLoanamount;

        require(pos.owedgoldShare >= shareToRemove, "Excessive repayment");

        pos.owedgoldShare -= shareToRemove;
        totalGolddebtShare -= shareToRemove;
        totalLoanamount -= amount;
    }

    function getPositionLoanamount(
        uint256 positionId
    ) external view returns (uint256) {
        Position storage pos = positions[positionId];

        if (totalGolddebtShare == 0) return 0;

        return (pos.owedgoldShare * totalLoanamount) / totalGolddebtShare;
    }

    function surrenderStake(uint256 positionId) external {
        Position storage pos = positions[positionId];

        uint256 owedGold = (pos.owedgoldShare * totalLoanamount) / totalGolddebtShare;

        require(pos.deposit * 100 < owedGold * 150, "Position is healthy");

        pos.deposit = 0;
        pos.owedgoldShare = 0;
    }
}
