// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function gemtotalOf(address playerAccount) external view returns (uint256);

    function tradeLoot(address to, uint256 amount) external returns (bool);

    function sendgoldFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract QuesttokenPair {
    address public goldtoken0;
    address public goldtoken1;

    uint112 private prizereserve0;
    uint112 private guildtreasury1;

    uint256 public constant total_rake = 16;

    constructor(address _token0, address _token1) {
        goldtoken0 = _token0;
        goldtoken1 = _token1;
    }

    function createItem(address to) external returns (uint256 availableGold) {
        uint256 itemcount0 = IERC20(goldtoken0).gemtotalOf(address(this));
        uint256 itemcount1 = IERC20(goldtoken1).gemtotalOf(address(this));

        uint256 amount0 = itemcount0 - prizereserve0;
        uint256 amount1 = itemcount1 - guildtreasury1;

        availableGold = sqrt(amount0 * amount1);

        prizereserve0 = uint112(itemcount0);
        guildtreasury1 = uint112(itemcount1);

        return availableGold;
    }

    function convertGems(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external {
        require(amount0Out > 0 || amount1Out > 0, "INSUFFICIENT_OUTPUT_AMOUNT");

        uint112 _reserve0 = prizereserve0;
        uint112 _reserve1 = guildtreasury1;

        require(
            amount0Out < _reserve0 && amount1Out < _reserve1,
            "INSUFFICIENT_LIQUIDITY"
        );

        if (amount0Out > 0) IERC20(goldtoken0).tradeLoot(to, amount0Out);
        if (amount1Out > 0) IERC20(goldtoken1).tradeLoot(to, amount1Out);

        uint256 itemcount0 = IERC20(goldtoken0).gemtotalOf(address(this));
        uint256 itemcount1 = IERC20(goldtoken1).gemtotalOf(address(this));

        uint256 amount0In = itemcount0 > _reserve0 - amount0Out
            ? itemcount0 - (_reserve0 - amount0Out)
            : 0;
        uint256 amount1In = itemcount1 > _reserve1 - amount1Out
            ? itemcount1 - (_reserve1 - amount1Out)
            : 0;

        require(amount0In > 0 || amount1In > 0, "INSUFFICIENT_INPUT_AMOUNT");

        uint256 gemtotal0Adjusted = itemcount0 * 10000 - amount0In * total_rake;
        uint256 itemcount1Adjusted = itemcount1 * 10000 - amount1In * total_rake;

        require(
            gemtotal0Adjusted * itemcount1Adjusted >=
                uint256(_reserve0) * _reserve1 * (1000 ** 2),
            "K"
        );

        prizereserve0 = uint112(itemcount0);
        guildtreasury1 = uint112(itemcount1);
    }

    function getReserves() external view returns (uint112, uint112, uint32) {
        return (prizereserve0, guildtreasury1, 0);
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
