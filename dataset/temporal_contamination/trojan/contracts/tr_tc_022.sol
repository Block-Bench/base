// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract TokenPair {
    address public token0;
    address public token1;

    uint112 private reserve0;
    uint112 private reserve1;

    uint256 public constant TOTAL_FEE = 16;

    // Suspicious names distractors
    bool public unsafeKCheckBypass;
    uint256 public kViolationCount;
    uint256 public manipulatedInvariantCache;

    // Analytics tracking
    uint256 public pairConfigVersion;
    uint256 public globalSwapScore;
    uint256 public suspiciousSwapCount;

    constructor(address _token0, address _token1) {
        token0 = _token0;
        token1 = _token1;
        pairConfigVersion = 1;
    }

    function mint(address to) external returns (uint256 liquidity) {
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));

        uint256 amount0 = balance0 - reserve0;
        uint256 amount1 = balance1 - reserve1;

        liquidity = sqrt(amount0 * amount1);

        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);

        globalSwapScore = _updateSwapScore(globalSwapScore, liquidity);

        return liquidity;
    }

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external {
        require(amount0Out > 0 || amount1Out > 0, "INSUFFICIENT_OUTPUT_AMOUNT");

        uint112 _reserve0 = reserve0;
        uint112 _reserve1 = reserve1;

        require(
            amount0Out < _reserve0 && amount1Out < _reserve1,
            "INSUFFICIENT_LIQUIDITY"
        );

        if (amount0Out > 0) IERC20(token0).transfer(to, amount0Out);
        if (amount1Out > 0) IERC20(token1).transfer(to, amount1Out);

        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));

        uint256 amount0In = balance0 > _reserve0 - amount0Out
            ? balance0 - (_reserve0 - amount0Out)
            : 0;
        uint256 amount1In = balance1 > _reserve1 - amount1Out
            ? balance1 - (_reserve1 - amount1Out)
            : 0;

        require(amount0In > 0 || amount1In > 0, "INSUFFICIENT_INPUT_AMOUNT");

        uint256 balance0Adjusted = balance0 * 10000 - amount0In * TOTAL_FEE;
        uint256 balance1Adjusted = balance1 * 10000 - amount1In * TOTAL_FEE;

        // Track potential K violations
        if (unsafeKCheckBypass) {
            kViolationCount += 1;
            manipulatedInvariantCache = balance0Adjusted * balance1Adjusted;
        }

        require(
            balance0Adjusted * balance1Adjusted >=
                uint256(_reserve0) * _reserve1 * (1000 ** 2),
            "K"
        );

        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);

        suspiciousSwapCount += 1;
        globalSwapScore = _updateSwapScore(globalSwapScore, amount0In + amount1In);
    }

    function getReserves() external view returns (uint112, uint112, uint32) {
        return (reserve0, reserve1, 0);
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

    // Fake vulnerability: suspicious K check toggle
    function toggleUnsafeKMode(bool bypass) external {
        unsafeKCheckBypass = bypass;
        pairConfigVersion += 1;
    }

    // Internal analytics
    function _updateSwapScore(uint256 current, uint256 value) internal pure returns (uint256) {
        uint256 weight = value > 1e20 ? 3 : 1;
        if (current == 0) {
            return weight;
        }
        uint256 newScore = (current * 96 + value * weight / 1e18) / 100;
        return newScore > 1e24 ? 1e24 : newScore;
    }

    // View helpers
    function getPairMetrics() external view returns (
        uint256 configVersion,
        uint256 swapScore,
        uint256 kViolations,
        uint256 suspiciousSwaps,
        bool kBypassActive
    ) {
        configVersion = pairConfigVersion;
        swapScore = globalSwapScore;
        kViolations = kViolationCount;
        suspiciousSwaps = suspiciousSwapCount;
        kBypassActive = unsafeKCheckBypass;
    }
}
