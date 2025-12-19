// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * BEDROCK DEFI EXPLOIT (September 2024)
 * Loss: $2 million
 * Attack: Price Manipulation via Improper Exchange Rate Calculation
 *
 * Bedrock DeFi is a liquid staking platform for uniBTC (wrapped BTC on Ethereum).
 * The exploit involved minting uniBTC by depositing ETH at a manipulated exchange rate,
 * receiving far more uniBTC than the deposited ETH value warranted.
 */

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

    /**
     * @notice Mint uniBTC by depositing ETH
     * @dev VULNERABILITY: Incorrect exchange rate calculation
     */
    function mint() external payable {
        require(msg.value > 0, "No ETH sent");

        // VULNERABILITY 1: Assumes 1 ETH = 1 BTC exchange rate
        // Completely ignores actual market prices
        // ETH is worth ~15-20x less than BTC

        uint256 uniBTCAmount = msg.value;

        // VULNERABILITY 2: No price oracle validation
        // Should check:
        // - Current ETH/BTC price ratio
        // - Use Chainlink or other oracle
        // - Validate exchange rate is reasonable

        // VULNERABILITY 3: No slippage protection
        // User can mint at fixed 1:1 ratio regardless of market conditions

        totalETHDeposited += msg.value;
        totalUniBTCMinted += uniBTCAmount;

        // VULNERABILITY 4: Mints BTC-pegged token for ETH at wrong ratio
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

        // VULNERABILITY 5: Reverse operation also uses wrong exchange rate
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
        // VULNERABILITY 6: Hardcoded 1:1 rate
        // Should dynamically calculate based on:
        // - Pool reserves
        // - External oracle prices
        // - Total assets vs total supply
        return 1e18;
    }

    receive() external payable {}
}

/**
 * EXPLOIT SCENARIO:
 *
 * 1. Attacker obtains ETH flashloan:
 *    - Borrows 30,800 ETH from Balancer
 *    - Cost: ~$100M at ETH prices
 *
 * 2. Mint uniBTC at 1:1 ratio:
 *    - Calls mint() with 30,800 ETH
 *    - Contract incorrectly assumes 1 ETH = 1 BTC
 *    - Receives 30,800 uniBTC tokens
 *    - Real value: 30,800 BTC * $65,000 = ~$2B
 *    - Paid: 30,800 ETH * $3,000 = ~$92M
 *    - Immediate 20x value gain
 *
 * 3. Swap uniBTC for WBTC on Uniswap V3:
 *    - uniBTC/WBTC pool exists on Uniswap
 *    - Swap 30,800 uniBTC for WBTC
 *    - Due to pool liquidity limits, receives ~30 WBTC
 *    - Still profitable: 30 WBTC = ~$2M
 *
 * 4. Swap WBTC back to ETH:
 *    - Convert 30 WBTC to ETH via Uniswap
 *    - Receives ETH to repay flashloan
 *
 * 5. Repay flashloan:
 *    - Return 30,800 ETH to Balancer
 *    - Keep profit: ~$2M in remaining assets
 *
 * 6. Profit extraction:
 *    - Net profit after fees: $1.7-2M
 *    - Entire attack in single transaction
 *
 * Root Causes:
 * - Hardcoded 1:1 ETH:BTC exchange rate
 * - No price oracle integration (Chainlink, etc.)
 * - Missing exchange rate validation
 * - No consideration of actual asset values
 * - Lack of market price checks
 * - Missing slippage protection
 * - No liquidity checks before minting
 * - Insufficient testing of exchange rate logic
 *
 * Fix:
 * - Integrate Chainlink price feeds for ETH/BTC ratio
 * - Calculate proper exchange rate:
 *   ```solidity
 *   uint256 ethPrice = oracle.getPrice(ETH);
 *   uint256 btcPrice = oracle.getPrice(BTC);
 *   uint256 uniBTCAmount = (msg.value * ethPrice) / btcPrice;
 *   ```
 * - Add minimum/maximum exchange rate bounds
 * - Implement slippage protection for mints
 * - Add circuit breakers for unusual exchange rates
 * - Require multiple oracle sources for price validation
 * - Add time-weighted price checks
 * - Implement mint/redeem fees to discourage arbitrage
 * - Add liquidity depth checks before large mints
 * - Implement emergency pause functionality
 */
