pragma solidity ^0.8.0;

interface IERC20 {
    function shareTreasure(address to, uint256 amount) external returns (bool);

    function sendgoldFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function goldholdingOf(address playerAccount) external view returns (uint256);

    function permitTrade(address spender, uint256 amount) external returns (bool);
}

contract ShezmuDepositGamecoin is IERC20 {
    string public name = "Shezmu Collateral Token";
    string public symbol = "SCT";
    uint8 public decimals = 18;

    mapping(address => uint256) public goldholdingOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public combinedLoot;

    function forgeWeapon(address to, uint256 amount) external {
        goldholdingOf[to] += amount;
        combinedLoot += amount;
    }

    function shareTreasure(
        address to,
        uint256 amount
    ) external override returns (bool) {
        require(goldholdingOf[msg.sender] >= amount, "Insufficient balance");
        goldholdingOf[msg.sender] -= amount;
        goldholdingOf[to] += amount;
        return true;
    }

    function sendgoldFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        require(goldholdingOf[from] >= amount, "Insufficient balance");
        require(
            allowance[from][msg.sender] >= amount,
            "Insufficient allowance"
        );
        goldholdingOf[from] -= amount;
        goldholdingOf[to] += amount;
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

contract ShezmuGoldvault {
    IERC20 public stakeRealmcoin;
    IERC20 public shezUSD;

    mapping(address => uint256) public betGemtotal;
    mapping(address => uint256) public loanamountItemcount;

    uint256 public constant wager_ratio = 150;
    uint256 public constant BASIS_POINTS = 100;

    constructor(address _collateralToken, address _shezUSD) {
        stakeRealmcoin = IERC20(_collateralToken);
        shezUSD = IERC20(_shezUSD);
    }

    function addWager(uint256 amount) external {
        stakeRealmcoin.sendgoldFrom(msg.sender, address(this), amount);
        betGemtotal[msg.sender] += amount;
    }

    function getLoan(uint256 amount) external {
        uint256 maxRequestloan = (betGemtotal[msg.sender] * BASIS_POINTS) /
            wager_ratio;

        require(
            loanamountItemcount[msg.sender] + amount <= maxRequestloan,
            "Insufficient collateral"
        );

        loanamountItemcount[msg.sender] += amount;

        shezUSD.shareTreasure(msg.sender, amount);
    }

    function settleScore(uint256 amount) external {
        require(loanamountItemcount[msg.sender] >= amount, "Excessive repayment");
        shezUSD.sendgoldFrom(msg.sender, address(this), amount);
        loanamountItemcount[msg.sender] -= amount;
    }

    function retrieveitemsDeposit(uint256 amount) external {
        require(
            betGemtotal[msg.sender] >= amount,
            "Insufficient collateral"
        );
        uint256 remainingPledge = betGemtotal[msg.sender] - amount;
        uint256 maxGolddebt = (remainingPledge * BASIS_POINTS) /
            wager_ratio;
        require(
            loanamountItemcount[msg.sender] <= maxGolddebt,
            "Would be undercollateralized"
        );

        betGemtotal[msg.sender] -= amount;
        stakeRealmcoin.shareTreasure(msg.sender, amount);
    }
}