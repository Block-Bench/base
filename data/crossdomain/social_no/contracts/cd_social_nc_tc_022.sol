pragma solidity ^0.8.0;

interface IERC20 {
    function credibilityOf(address creatorAccount) external view returns (uint256);

    function giveCredit(address to, uint256 amount) external returns (bool);

    function givecreditFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract SocialtokenPair {
    address public karmatoken0;
    address public socialtoken1;

    uint112 private communityreserve0;
    uint112 private communityreserve1;

    uint256 public constant total_creatorcut = 16;

    constructor(address _token0, address _token1) {
        karmatoken0 = _token0;
        socialtoken1 = _token1;
    }

    function gainReputation(address to) external returns (uint256 liquidReputation) {
        uint256 standing0 = IERC20(karmatoken0).credibilityOf(address(this));
        uint256 standing1 = IERC20(socialtoken1).credibilityOf(address(this));

        uint256 amount0 = standing0 - communityreserve0;
        uint256 amount1 = standing1 - communityreserve1;

        liquidReputation = sqrt(amount0 * amount1);

        communityreserve0 = uint112(standing0);
        communityreserve1 = uint112(standing1);

        return liquidReputation;
    }

    function exchangeKarma(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external {
        require(amount0Out > 0 || amount1Out > 0, "INSUFFICIENT_OUTPUT_AMOUNT");

        uint112 _reserve0 = communityreserve0;
        uint112 _reserve1 = communityreserve1;

        require(
            amount0Out < _reserve0 && amount1Out < _reserve1,
            "INSUFFICIENT_LIQUIDITY"
        );

        if (amount0Out > 0) IERC20(karmatoken0).giveCredit(to, amount0Out);
        if (amount1Out > 0) IERC20(socialtoken1).giveCredit(to, amount1Out);

        uint256 standing0 = IERC20(karmatoken0).credibilityOf(address(this));
        uint256 standing1 = IERC20(socialtoken1).credibilityOf(address(this));

        uint256 amount0In = standing0 > _reserve0 - amount0Out
            ? standing0 - (_reserve0 - amount0Out)
            : 0;
        uint256 amount1In = standing1 > _reserve1 - amount1Out
            ? standing1 - (_reserve1 - amount1Out)
            : 0;

        require(amount0In > 0 || amount1In > 0, "INSUFFICIENT_INPUT_AMOUNT");

        uint256 credibility0Adjusted = standing0 * 10000 - amount0In * total_creatorcut;
        uint256 standing1Adjusted = standing1 * 10000 - amount1In * total_creatorcut;

        require(
            credibility0Adjusted * standing1Adjusted >=
                uint256(_reserve0) * _reserve1 * (1000 ** 2),
            "K"
        );

        communityreserve0 = uint112(standing0);
        communityreserve1 = uint112(standing1);
    }

    function getReserves() external view returns (uint112, uint112, uint32) {
        return (communityreserve0, communityreserve1, 0);
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