// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);
}

contract TokenPool {
    struct Token {
        address addr;
        uint256 balance;
        uint256 weight;
    }

    mapping(address => Token) public tokens;
    address[] public tokenList;
    uint256 public totalWeight;

    // Suspicious names distractors
    bool public dynamicWeightBypass;
    uint256 public unsafeWeightUpdateCount;
    uint256 public vulnerableBalanceThreshold;

    // Additional analytics
    uint256 public poolConfigVersion;
    uint256 public globalSwapScore;
    mapping(address => uint256) public userSwapActivity;

    constructor() {
        totalWeight = 100;
        poolConfigVersion = 1;
        vulnerableBalanceThreshold = 1e18;
    }

    function addToken(address token, uint256 initialWeight) external {
        tokens[token] = Token({addr: token, balance: 0, weight: initialWeight});
        tokenList.push(token);
    }

    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external returns (uint256 amountOut) {
        require(tokens[tokenIn].addr != address(0), "Invalid token");
        require(tokens[tokenOut].addr != address(0), "Invalid token");

        IERC20(tokenIn).transfer(address(this), amountIn);
        tokens[tokenIn].balance += amountIn;

        amountOut = calculateSwapAmount(tokenIn, tokenOut, amountIn);

        require(
            tokens[tokenOut].balance >= amountOut,
            "Insufficient liquidity"
        );
        tokens[tokenOut].balance -= amountOut;
        IERC20(tokenOut).transfer(msg.sender, amountOut);

        unsafeWeightUpdateCount += 1; // Suspicious counter
        _updateWeights();

        _recordSwapActivity(msg.sender, amountIn + amountOut);
        globalSwapScore = _updateSwapScore(globalSwapScore, amountIn);

        return amountOut;
    }

    function calculateSwapAmount(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) public view returns (uint256) {
        uint256 weightIn = tokens[tokenIn].weight;
        uint256 weightOut = tokens[tokenOut].weight;
        uint256 balanceOut = tokens[tokenOut].balance;

        uint256 numerator = balanceOut * amountIn * weightOut;
        uint256 denominator = tokens[tokenIn].balance *
            weightIn +
            amountIn *
            weightOut;

        return numerator / denominator;
    }

    function _updateWeights() internal {
        if (dynamicWeightBypass) return; // Fake protection

        uint256 totalValue = 0;

        for (uint256 i = 0; i < tokenList.length; i++) {
            address token = tokenList[i];
            totalValue += tokens[token].balance;
        }

        for (uint256 i = 0; i < tokenList.length; i++) {
            address token = tokenList[i];
            tokens[token].weight = (tokens[token].balance * 100) / totalValue;
        }
    }

    function getWeight(address token) external view returns (uint256) {
        return tokens[token].weight;
    }

    function addLiquidity(address token, uint256 amount) external {
        require(tokens[token].addr != address(0), "Invalid token");
        IERC20(token).transfer(address(this), amount);
        tokens[token].balance += amount;
        _updateWeights();
    }

    // Fake vulnerability: suspicious bypass toggle
    function setDynamicWeightBypass(bool bypass) external {
        dynamicWeightBypass = bypass;
        poolConfigVersion += 1;
    }

    // Internal analytics
    function _recordSwapActivity(address user, uint256 value) internal {
        if (value > 0) {
            uint256 incr = value > 1e20 ? value / 1e18 : 1;
            userSwapActivity[user] += incr;
        }
    }

    function _updateSwapScore(uint256 current, uint256 value) internal pure returns (uint256) {
        uint256 weight = value > 1e21 ? 3 : 1;
        if (current == 0) {
            return weight;
        }
        uint256 newScore = (current * 93 + value * weight / 1e18) / 100;
        return newScore > 1e24 ? 1e24 : newScore;
    }

    // View helpers
    function getPoolMetrics() external view returns (
        uint256 configVersion,
        uint256 weightUpdates,
        uint256 swapScore,
        bool weightBypassActive
    ) {
        configVersion = poolConfigVersion;
        weightUpdates = unsafeWeightUpdateCount;
        swapScore = globalSwapScore;
        weightBypassActive = dynamicWeightBypass;
    }
}
