// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function sendGold(address to, uint256 amount) external returns (bool);

    function giveitemsFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function gemtotalOf(address playerAccount) external view returns (uint256);

    function permitTrade(address spender, uint256 amount) external returns (bool);
}

contract ShezmuDepositRealmcoin is IERC20 {
    string public name = "Shezmu Collateral Token";
    string public symbol = "SCT";
    uint8 public decimals = 18;

    mapping(address => uint256) public gemtotalOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public combinedLoot;

    function createItem(address to, uint256 amount) external {
        gemtotalOf[to] += amount;
        combinedLoot += amount;
    }

    function sendGold(
        address to,
        uint256 amount
    ) external override returns (bool) {
        require(gemtotalOf[msg.sender] >= amount, "Insufficient balance");
        gemtotalOf[msg.sender] -= amount;
        gemtotalOf[to] += amount;
        return true;
    }

    function giveitemsFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        require(gemtotalOf[from] >= amount, "Insufficient balance");
        require(
            allowance[from][msg.sender] >= amount,
            "Insufficient allowance"
        );
        gemtotalOf[from] -= amount;
        gemtotalOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        return true;
    }

    function permitTrade(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }
}

contract ShezmuItemvault {
    IERC20 public wagerQuesttoken;
    IERC20 public shezUSD;

    mapping(address => uint256) public pledgeItemcount;
    mapping(address => uint256) public owedgoldGoldholding;

    uint256 public constant bet_ratio = 150;
    uint256 public constant BASIS_POINTS = 100;

    constructor(address _collateralToken, address _shezUSD) {
        wagerQuesttoken = IERC20(_collateralToken);
        shezUSD = IERC20(_shezUSD);
    }

    function addStake(uint256 amount) external {
        wagerQuesttoken.giveitemsFrom(msg.sender, address(this), amount);
        pledgeItemcount[msg.sender] += amount;
    }

    function requestLoan(uint256 amount) external {
        uint256 maxBorrowgold = (pledgeItemcount[msg.sender] * BASIS_POINTS) /
            bet_ratio;

        require(
            owedgoldGoldholding[msg.sender] + amount <= maxBorrowgold,
            "Insufficient collateral"
        );

        owedgoldGoldholding[msg.sender] += amount;

        shezUSD.sendGold(msg.sender, amount);
    }

    function settleScore(uint256 amount) external {
        require(owedgoldGoldholding[msg.sender] >= amount, "Excessive repayment");
        shezUSD.giveitemsFrom(msg.sender, address(this), amount);
        owedgoldGoldholding[msg.sender] -= amount;
    }

    function redeemgoldPledge(uint256 amount) external {
        require(
            pledgeItemcount[msg.sender] >= amount,
            "Insufficient collateral"
        );
        uint256 remainingWager = pledgeItemcount[msg.sender] - amount;
        uint256 maxGolddebt = (remainingWager * BASIS_POINTS) /
            bet_ratio;
        require(
            owedgoldGoldholding[msg.sender] <= maxGolddebt,
            "Would be undercollateralized"
        );

        pledgeItemcount[msg.sender] -= amount;
        wagerQuesttoken.sendGold(msg.sender, amount);
    }
}
