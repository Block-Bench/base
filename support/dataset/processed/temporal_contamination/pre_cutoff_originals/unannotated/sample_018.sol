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

    constructor() {
        totalWeight = 100;
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

        _updateWeights();

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
}
