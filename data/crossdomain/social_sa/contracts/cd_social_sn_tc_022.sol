// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function standingOf(address profile) external view returns (uint256);

    function giveCredit(address to, uint256 amount) external returns (bool);

    function sendtipFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract SocialtokenPair {
    address public reputationtoken0;
    address public reputationtoken1;

    uint112 private patronreserve0;
    uint112 private communityreserve1;

    uint256 public constant total_creatorcut = 16;

    constructor(address _token0, address _token1) {
        reputationtoken0 = _token0;
        reputationtoken1 = _token1;
    }

    function earnKarma(address to) external returns (uint256 availableKarma) {
        uint256 credibility0 = IERC20(reputationtoken0).standingOf(address(this));
        uint256 credibility1 = IERC20(reputationtoken1).standingOf(address(this));

        uint256 amount0 = credibility0 - patronreserve0;
        uint256 amount1 = credibility1 - communityreserve1;

        availableKarma = sqrt(amount0 * amount1);

        patronreserve0 = uint112(credibility0);
        communityreserve1 = uint112(credibility1);

        return availableKarma;
    }

    function tradeInfluence(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external {
        require(amount0Out > 0 || amount1Out > 0, "INSUFFICIENT_OUTPUT_AMOUNT");

        uint112 _reserve0 = patronreserve0;
        uint112 _reserve1 = communityreserve1;

        require(
            amount0Out < _reserve0 && amount1Out < _reserve1,
            "INSUFFICIENT_LIQUIDITY"
        );

        if (amount0Out > 0) IERC20(reputationtoken0).giveCredit(to, amount0Out);
        if (amount1Out > 0) IERC20(reputationtoken1).giveCredit(to, amount1Out);

        uint256 credibility0 = IERC20(reputationtoken0).standingOf(address(this));
        uint256 credibility1 = IERC20(reputationtoken1).standingOf(address(this));

        uint256 amount0In = credibility0 > _reserve0 - amount0Out
            ? credibility0 - (_reserve0 - amount0Out)
            : 0;
        uint256 amount1In = credibility1 > _reserve1 - amount1Out
            ? credibility1 - (_reserve1 - amount1Out)
            : 0;

        require(amount0In > 0 || amount1In > 0, "INSUFFICIENT_INPUT_AMOUNT");

        uint256 standing0Adjusted = credibility0 * 10000 - amount0In * total_creatorcut;
        uint256 credibility1Adjusted = credibility1 * 10000 - amount1In * total_creatorcut;

        require(
            standing0Adjusted * credibility1Adjusted >=
                uint256(_reserve0) * _reserve1 * (1000 ** 2),
            "K"
        );

        patronreserve0 = uint112(credibility0);
        communityreserve1 = uint112(credibility1);
    }

    function getReserves() external view returns (uint112, uint112, uint32) {
        return (patronreserve0, communityreserve1, 0);
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
