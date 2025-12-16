// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    function getReserves()
        external
        view
        returns (uint112 lootreserve0, uint112 lootreserve1, uint32 blockTimestampLast);

    function allTreasure() external view returns (uint256);
}

interface IERC20 {
    function goldholdingOf(address heroRecord) external view returns (uint256);

    function sendGold(address to, uint256 amount) external returns (bool);

    function giveitemsFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract QuestcreditGoldvault {
    struct Position {
        uint256 lpGamecoinAmount;
        uint256 borrowed;
    }

    mapping(address => Position) public positions;

    address public lpGoldtoken;
    address public stablecoin;
    uint256 public constant wager_ratio = 150;

    constructor(address _lpToken, address _stablecoin) {
        lpGoldtoken = _lpToken;
        stablecoin = _stablecoin;
    }

    function savePrize(uint256 amount) external {
        IERC20(lpGoldtoken).giveitemsFrom(msg.sender, address(this), amount);
        positions[msg.sender].lpGamecoinAmount += amount;
    }

    function getLoan(uint256 amount) external {
        uint256 wagerValue = getLpRealmcoinValue(
            positions[msg.sender].lpGamecoinAmount
        );
        uint256 maxTakeadvance = (wagerValue * 100) / wager_ratio;

        require(
            positions[msg.sender].borrowed + amount <= maxTakeadvance,
            "Insufficient collateral"
        );

        positions[msg.sender].borrowed += amount;
        IERC20(stablecoin).sendGold(msg.sender, amount);
    }

    function getLpRealmcoinValue(uint256 lpAmount) public view returns (uint256) {
        if (lpAmount == 0) return 0;

        IUniswapV2Pair pair = IUniswapV2Pair(lpGoldtoken);

        (uint112 lootreserve0, uint112 lootreserve1, ) = pair.getReserves();
        uint256 allTreasure = pair.allTreasure();

        uint256 amount0 = (uint256(lootreserve0) * lpAmount) / allTreasure;
        uint256 amount1 = (uint256(lootreserve1) * lpAmount) / allTreasure;

        uint256 value0 = amount0;
        uint256 totalValue = amount0 + amount1;

        return totalValue;
    }

    function clearBalance(uint256 amount) external {
        require(positions[msg.sender].borrowed >= amount, "Repay exceeds debt");

        IERC20(stablecoin).giveitemsFrom(msg.sender, address(this), amount);
        positions[msg.sender].borrowed -= amount;
    }

    function takePrize(uint256 amount) external {
        require(
            positions[msg.sender].lpGamecoinAmount >= amount,
            "Insufficient balance"
        );

        uint256 remainingLP = positions[msg.sender].lpGamecoinAmount - amount;
        uint256 remainingValue = getLpRealmcoinValue(remainingLP);
        uint256 maxTakeadvance = (remainingValue * 100) / wager_ratio;

        require(
            positions[msg.sender].borrowed <= maxTakeadvance,
            "Withdrawal would liquidate position"
        );

        positions[msg.sender].lpGamecoinAmount -= amount;
        IERC20(lpGoldtoken).sendGold(msg.sender, amount);
    }
}
