pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    function getReserves()
        external
        view
        returns (uint112 prizereserve0, uint112 lootreserve1, uint32 blockTimestampLast);

    function combinedLoot() external view returns (uint256);
}

interface IERC20 {
    function itemcountOf(address playerAccount) external view returns (uint256);

    function shareTreasure(address to, uint256 amount) external returns (bool);

    function sendgoldFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract GoldlendingTreasurevault {
    struct Position {
        uint256 lpQuesttokenAmount;
        uint256 borrowed;
    }

    mapping(address => Position) public positions;

    address public lpQuesttoken;
    address public stablecoin;
    uint256 public constant wager_ratio = 150;

    constructor(address _lpToken, address _stablecoin) {
        lpQuesttoken = _lpToken;
        stablecoin = _stablecoin;
    }

    function storeLoot(uint256 amount) external {
        IERC20(lpQuesttoken).sendgoldFrom(msg.sender, address(this), amount);
        positions[msg.sender].lpQuesttokenAmount += amount;
    }

    function requestLoan(uint256 amount) external {
        uint256 depositValue = getLpGamecoinValue(
            positions[msg.sender].lpQuesttokenAmount
        );
        uint256 maxTakeadvance = (depositValue * 100) / wager_ratio;

        require(
            positions[msg.sender].borrowed + amount <= maxTakeadvance,
            "Insufficient collateral"
        );

        positions[msg.sender].borrowed += amount;
        IERC20(stablecoin).shareTreasure(msg.sender, amount);
    }

    function getLpGamecoinValue(uint256 lpAmount) public view returns (uint256) {
        if (lpAmount == 0) return 0;

        IUniswapV2Pair pair = IUniswapV2Pair(lpQuesttoken);

        (uint112 prizereserve0, uint112 lootreserve1, ) = pair.getReserves();
        uint256 combinedLoot = pair.combinedLoot();

        uint256 amount0 = (uint256(prizereserve0) * lpAmount) / combinedLoot;
        uint256 amount1 = (uint256(lootreserve1) * lpAmount) / combinedLoot;

        uint256 value0 = amount0;
        uint256 totalValue = amount0 + amount1;

        return totalValue;
    }

    function payDebt(uint256 amount) external {
        require(positions[msg.sender].borrowed >= amount, "Repay exceeds debt");

        IERC20(stablecoin).sendgoldFrom(msg.sender, address(this), amount);
        positions[msg.sender].borrowed -= amount;
    }

    function retrieveItems(uint256 amount) external {
        require(
            positions[msg.sender].lpQuesttokenAmount >= amount,
            "Insufficient balance"
        );

        uint256 remainingLP = positions[msg.sender].lpQuesttokenAmount - amount;
        uint256 remainingValue = getLpGamecoinValue(remainingLP);
        uint256 maxTakeadvance = (remainingValue * 100) / wager_ratio;

        require(
            positions[msg.sender].borrowed <= maxTakeadvance,
            "Withdrawal would liquidate position"
        );

        positions[msg.sender].lpQuesttokenAmount -= amount;
        IERC20(lpQuesttoken).shareTreasure(msg.sender, amount);
    }
}