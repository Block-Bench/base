pragma solidity ^0.8.0;

interface IERC20 {
    function itemcountOf(address gamerProfile) external view returns (uint256);

    function tradeLoot(address to, uint256 amount) external returns (bool);

    function tradelootFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract QuesttokenPair {
    address public gamecoin0;
    address public questtoken1;

    uint112 private guildtreasury0;
    uint112 private guildtreasury1;

    uint256 public constant total_rake = 16;

    constructor(address _token0, address _token1) {
        gamecoin0 = _token0;
        questtoken1 = _token1;
    }

    function forgeWeapon(address to) external returns (uint256 tradableAssets) {
        uint256 gemtotal0 = IERC20(gamecoin0).itemcountOf(address(this));
        uint256 gemtotal1 = IERC20(questtoken1).itemcountOf(address(this));

        uint256 amount0 = gemtotal0 - guildtreasury0;
        uint256 amount1 = gemtotal1 - guildtreasury1;

        tradableAssets = sqrt(amount0 * amount1);

        guildtreasury0 = uint112(gemtotal0);
        guildtreasury1 = uint112(gemtotal1);

        return tradableAssets;
    }

    function tradeItems(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external {
        require(amount0Out > 0 || amount1Out > 0, "INSUFFICIENT_OUTPUT_AMOUNT");

        uint112 _reserve0 = guildtreasury0;
        uint112 _reserve1 = guildtreasury1;

        require(
            amount0Out < _reserve0 && amount1Out < _reserve1,
            "INSUFFICIENT_LIQUIDITY"
        );

        if (amount0Out > 0) IERC20(gamecoin0).tradeLoot(to, amount0Out);
        if (amount1Out > 0) IERC20(questtoken1).tradeLoot(to, amount1Out);

        uint256 gemtotal0 = IERC20(gamecoin0).itemcountOf(address(this));
        uint256 gemtotal1 = IERC20(questtoken1).itemcountOf(address(this));

        uint256 amount0In = gemtotal0 > _reserve0 - amount0Out
            ? gemtotal0 - (_reserve0 - amount0Out)
            : 0;
        uint256 amount1In = gemtotal1 > _reserve1 - amount1Out
            ? gemtotal1 - (_reserve1 - amount1Out)
            : 0;

        require(amount0In > 0 || amount1In > 0, "INSUFFICIENT_INPUT_AMOUNT");

        uint256 itemcount0Adjusted = gemtotal0 * 10000 - amount0In * total_rake;
        uint256 gemtotal1Adjusted = gemtotal1 * 10000 - amount1In * total_rake;

        require(
            itemcount0Adjusted * gemtotal1Adjusted >=
                uint256(_reserve0) * _reserve1 * (1000 ** 2),
            "K"
        );

        guildtreasury0 = uint112(gemtotal0);
        guildtreasury1 = uint112(gemtotal1);
    }

    function getReserves() external view returns (uint112, uint112, uint32) {
        return (guildtreasury0, guildtreasury1, 0);
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