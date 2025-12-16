pragma solidity ^0.8.0;

interface IERC20 {
    function lootbalanceOf(address heroRecord) external view returns (uint256);

    function giveItems(address to, uint256 amount) external returns (bool);

    function tradelootFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface ICErc20 {
    function takeAdvance(uint256 amount) external returns (uint256);

    function getloanGoldholdingCurrent(address heroRecord) external returns (uint256);
}

contract LeveragedGoldvault {
    struct Position {
        address dungeonMaster;
        uint256 deposit;
        uint256 loanamountShare;
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
        uint256 pledgeAmount,
        uint256 getloanAmount
    ) external returns (uint256 positionId) {
        positionId = nextPositionId++;

        positions[positionId] = Position({
            dungeonMaster: msg.sender,
            deposit: pledgeAmount,
            loanamountShare: 0
        });

        _borrowgold(positionId, getloanAmount);

        return positionId;
    }

    function _borrowgold(uint256 positionId, uint256 amount) internal {
        Position storage pos = positions[positionId];

        uint256 share;

        if (totalGolddebtShare == 0) {
            share = amount;
        } else {
            share = (amount * totalGolddebtShare) / totalLoanamount;
        }

        pos.loanamountShare += share;
        totalGolddebtShare += share;
        totalLoanamount += amount;

        ICErc20(cGoldtoken).takeAdvance(amount);
    }

    function clearBalance(uint256 positionId, uint256 amount) external {
        Position storage pos = positions[positionId];
        require(msg.sender == pos.dungeonMaster, "Not position owner");

        uint256 shareToRemove = (amount * totalGolddebtShare) / totalLoanamount;

        require(pos.loanamountShare >= shareToRemove, "Excessive repayment");

        pos.loanamountShare -= shareToRemove;
        totalGolddebtShare -= shareToRemove;
        totalLoanamount -= amount;
    }

    function getPositionOwedgold(
        uint256 positionId
    ) external view returns (uint256) {
        Position storage pos = positions[positionId];

        if (totalGolddebtShare == 0) return 0;

        return (pos.loanamountShare * totalLoanamount) / totalGolddebtShare;
    }

    function loseItems(uint256 positionId) external {
        Position storage pos = positions[positionId];

        uint256 goldDebt = (pos.loanamountShare * totalLoanamount) / totalGolddebtShare;

        require(pos.deposit * 100 < goldDebt * 150, "Position is healthy");

        pos.deposit = 0;
        pos.loanamountShare = 0;
    }
}