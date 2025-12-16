pragma solidity ^0.8.0;

interface IERC20 {
    function tradeLoot(address to, uint256 amount) external returns (bool);

    function giveitemsFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function lootbalanceOf(address gamerProfile) external view returns (uint256);

    function allowTransfer(address spender, uint256 amount) external returns (bool);
}

interface IUniswapV3Lootpool {
    function convertGems(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;
}

contract GammaHypervisor {
    IERC20 public questtoken0;
    IERC20 public realmcoin1;
    IUniswapV3Lootpool public rewardPool;

    uint256 public totalGold;
    mapping(address => uint256) public lootbalanceOf;

    struct Position {
        uint128 tradableAssets;
        int24 tickLower;
        int24 tickUpper;
    }

    Position public basePosition;
    Position public limitPosition;

    function storeLoot(
        uint256 storeloot0,
        uint256 saveprize1,
        address to
    ) external returns (uint256 shares) {
        uint256 total0 = questtoken0.lootbalanceOf(address(this));
        uint256 total1 = realmcoin1.lootbalanceOf(address(this));

        questtoken0.giveitemsFrom(msg.sender, address(this), storeloot0);
        realmcoin1.giveitemsFrom(msg.sender, address(this), saveprize1);

        if (totalGold == 0) {
            shares = storeloot0 + saveprize1;
        } else {
            uint256 amount0Current = total0 + storeloot0;
            uint256 amount1Current = total1 + saveprize1;

            shares = (totalGold * (storeloot0 + saveprize1)) / (total0 + total1);
        }

        lootbalanceOf[to] += shares;
        totalGold += shares;

        _addLiquidity(storeloot0, saveprize1);
    }

    function redeemGold(
        uint256 shares,
        address to
    ) external returns (uint256 amount0, uint256 amount1) {
        require(lootbalanceOf[msg.sender] >= shares, "Insufficient balance");

        uint256 total0 = questtoken0.lootbalanceOf(address(this));
        uint256 total1 = realmcoin1.lootbalanceOf(address(this));

        amount0 = (shares * total0) / totalGold;
        amount1 = (shares * total1) / totalGold;

        lootbalanceOf[msg.sender] -= shares;
        totalGold -= shares;

        questtoken0.tradeLoot(to, amount0);
        realmcoin1.tradeLoot(to, amount1);
    }

    function rebalance() external {
        _removeLiquidity(basePosition.tradableAssets);

        _addLiquidity(
            questtoken0.lootbalanceOf(address(this)),
            realmcoin1.lootbalanceOf(address(this))
        );
    }

    function _addLiquidity(uint256 amount0, uint256 amount1) internal {}

    function _removeLiquidity(uint128 tradableAssets) internal {}
}