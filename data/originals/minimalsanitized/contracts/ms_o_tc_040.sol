// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
}

interface IUniswapV3Router {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint256 amountOut);
}

contract BedrockVault {
    IERC20 public immutable uniBTC;
    IERC20 public immutable WBTC;
    IUniswapV3Router public immutable router;

    uint256 public totalETHDeposited;
    uint256 public totalUniBTCMinted;

    constructor(address _uniBTC, address _wbtc, address _router) {
        uniBTC = IERC20(_uniBTC);
        WBTC = IERC20(_wbtc);
        router = IUniswapV3Router(_router);
    }

    function mint() external payable {
        require(msg.value > 0, "No ETH sent");

        // Completely ignores actual market prices
        // ETH is worth ~15-20x less than BTC

        uint256 uniBTCAmount = msg.value;

        // Should check:
        // - Current ETH/BTC price ratio
        // - Use Chainlink or other oracle
        // - Validate exchange rate is reasonable

        // User can mint at fixed 1:1 ratio regardless of market conditions

        totalETHDeposited += msg.value;
        totalUniBTCMinted += uniBTCAmount;

        // User deposits 1 ETH (~$3000)
        // Gets 1 uniBTC (~$60000 value)
        // 20x value extraction

        // Transfer uniBTC to user
        uniBTC.transfer(msg.sender, uniBTCAmount);
    }

    /**
     * @notice Redeem ETH by burning uniBTC
     */
    function redeem(uint256 amount) external {
        require(amount > 0, "No amount specified");
        require(uniBTC.balanceOf(msg.sender) >= amount, "Insufficient balance");

        // Would allow draining ETH at incorrect ratio

        uniBTC.transferFrom(msg.sender, address(this), amount);

        uint256 ethAmount = amount;
        require(address(this).balance >= ethAmount, "Insufficient ETH");

        payable(msg.sender).transfer(ethAmount);
    }

    /**
     * @notice Get current exchange rate
     * @dev Should return ETH per uniBTC, but returns 1:1
     */
    function getExchangeRate() external pure returns (uint256) {
        // Should dynamically calculate based on:
        // - Pool reserves
        // - External oracle prices
        // - Total assets vs total supply
        return 1e18;
    }

    receive() external payable {}
}
