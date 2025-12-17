// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function shareTreasure(address to, uint256 amount) external returns (bool);

    function sharetreasureFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function treasurecountOf(address heroRecord) external view returns (uint256);

    function allowTransfer(address spender, uint256 amount) external returns (bool);
}

interface IUniswapV3Prizepool {
    function tradeItems(
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
    IERC20 public goldtoken1;
    IUniswapV3Prizepool public prizePool;

    uint256 public combinedLoot;
    mapping(address => uint256) public treasurecountOf;

    struct Position {
        uint128 availableGold;
        int24 tickLower;
        int24 tickUpper;
    }

    Position public basePosition;
    Position public limitPosition;

    function stashItems(
        uint256 stashitems0,
        uint256 stashitems1,
        address to
    ) external returns (uint256 shares) {
        uint256 total0 = questtoken0.treasurecountOf(address(this));
        uint256 total1 = goldtoken1.treasurecountOf(address(this));

        questtoken0.sharetreasureFrom(msg.sender, address(this), stashitems0);
        goldtoken1.sharetreasureFrom(msg.sender, address(this), stashitems1);

        if (combinedLoot == 0) {
            shares = stashitems0 + stashitems1;
        } else {
            uint256 amount0Current = total0 + stashitems0;
            uint256 amount1Current = total1 + stashitems1;

            shares = (combinedLoot * (stashitems0 + stashitems1)) / (total0 + total1);
        }

        treasurecountOf[to] += shares;
        combinedLoot += shares;

        _addLiquidity(stashitems0, stashitems1);
    }

    function retrieveItems(
        uint256 shares,
        address to
    ) external returns (uint256 amount0, uint256 amount1) {
        require(treasurecountOf[msg.sender] >= shares, "Insufficient balance");

        uint256 total0 = questtoken0.treasurecountOf(address(this));
        uint256 total1 = goldtoken1.treasurecountOf(address(this));

        amount0 = (shares * total0) / combinedLoot;
        amount1 = (shares * total1) / combinedLoot;

        treasurecountOf[msg.sender] -= shares;
        combinedLoot -= shares;

        questtoken0.shareTreasure(to, amount0);
        goldtoken1.shareTreasure(to, amount1);
    }

    function rebalance() external {
        _removeLiquidity(basePosition.availableGold);

        _addLiquidity(
            questtoken0.treasurecountOf(address(this)),
            goldtoken1.treasurecountOf(address(this))
        );
    }

    function _addLiquidity(uint256 amount0, uint256 amount1) internal {}

    function _removeLiquidity(uint128 availableGold) internal {}
}
