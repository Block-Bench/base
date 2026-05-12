// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * GAMMA STRATEGIES EXPLOIT (January 2024)
 * Loss: $6.1 million
 * Attack: Liquidity Management Deposit/Withdrawal Manipulation
 *
 * Gamma Strategies managed liquidity positions on Uniswap V3/Algebra pools.
 * Attackers manipulated the deposit/withdrawal process through price manipulation
 * and exploited the vault's liquidity management to drain funds.
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

interface IUniswapV3Pool {
    function swap(
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
    IERC20 public token0;
    IERC20 public token1;
    IUniswapV3Pool public pool;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    struct Position {
        uint128 liquidity;
        int24 tickLower;
        int24 tickUpper;
    }

    Position public basePosition;
    Position public limitPosition;

    /**
     * @notice Deposit tokens and receive vault shares
     * @dev VULNERABLE: Deposits can be manipulated through price changes
     */
    function deposit(
        uint256 deposit0,
        uint256 deposit1,
        address to
    ) external returns (uint256 shares) {
        // VULNERABILITY 1: Share calculation based on current pool state
        // Price manipulation affects share issuance

        // Get current pool reserves (simplified)
        uint256 total0 = token0.balanceOf(address(this));
        uint256 total1 = token1.balanceOf(address(this));

        // Transfer tokens from user
        token0.transferFrom(msg.sender, address(this), deposit0);
        token1.transferFrom(msg.sender, address(this), deposit1);

        // VULNERABILITY 2: No slippage protection on share calculation
        // Attacker can manipulate price before deposit to get more shares
        if (totalSupply == 0) {
            shares = deposit0 + deposit1;
        } else {
            // Calculate shares based on current value
            uint256 amount0Current = total0 + deposit0;
            uint256 amount1Current = total1 + deposit1;

            shares = (totalSupply * (deposit0 + deposit1)) / (total0 + total1);
        }

        // VULNERABILITY 3: No check if deposits are balanced according to pool ratio
        // Allows depositing unbalanced amounts at manipulated prices

        balanceOf[to] += shares;
        totalSupply += shares;

        // Add liquidity to pool positions (simplified)
        _addLiquidity(deposit0, deposit1);
    }

    /**
     * @notice Withdraw tokens by burning shares
     * @dev VULNERABLE: Withdrawals affected by manipulated pool state
     */
    function withdraw(
        uint256 shares,
        address to
    ) external returns (uint256 amount0, uint256 amount1) {
        require(balanceOf[msg.sender] >= shares, "Insufficient balance");

        // VULNERABILITY 4: Withdrawal amounts based on current manipulated state
        // Attacker can withdraw more value after price manipulation

        uint256 total0 = token0.balanceOf(address(this));
        uint256 total1 = token1.balanceOf(address(this));

        // Calculate withdrawal amounts proportional to shares
        amount0 = (shares * total0) / totalSupply;
        amount1 = (shares * total1) / totalSupply;

        balanceOf[msg.sender] -= shares;
        totalSupply -= shares;

        // Transfer tokens to user
        token0.transfer(to, amount0);
        token1.transfer(to, amount1);
    }

    /**
     * @notice Rebalance liquidity positions
     * @dev VULNERABLE: Can be called during price manipulation
     */
    function rebalance() external {
        // VULNERABILITY 5: Rebalancing during manipulated price locks in bad state
        // No protection against sandwich attacks during rebalance

        _removeLiquidity(basePosition.liquidity);

        // Recalculate position ranges based on current price
        // This happens at manipulated price point

        _addLiquidity(
            token0.balanceOf(address(this)),
            token1.balanceOf(address(this))
        );
    }

    function _addLiquidity(uint256 amount0, uint256 amount1) internal {
        // Simplified liquidity addition
    }

    function _removeLiquidity(uint128 liquidity) internal {
        // Simplified liquidity removal
    }
}

/**
 * EXPLOIT SCENARIO:
 *
 * 1. Attacker obtains large flashloans:
 *    - 3000 USDT from Uniswap V3
 *    - 2000 USDCe from Balancer
 *
 * 2. Price manipulation phase 1:
 *    - Swap large amounts to manipulate Algebra pool price
 *    - Execute 15 iterations of swaps through the pool
 *    - Price moves significantly from true value
 *
 * 3. Interact with Gamma Hypervisor during manipulation:
 *    - Deposit tokens at manipulated price
 *    - Receive inflated share amounts due to incorrect valuation
 *    - Or withdraw at manipulated price for better token amounts
 *
 * 4. Price manipulation phase 2:
 *    - Trigger rebalance operations during manipulation
 *    - Gamma vault rebalances at incorrect price
 *    - Locks in losses for the vault
 *
 * 5. Restore price and withdraw:
 *    - Perform reverse swaps to restore pool price
 *    - Withdraw from Gamma at corrected price
 *    - Profit from the price discrepancy
 *
 * 6. Repay flashloans and keep profit:
 *    - Return borrowed tokens
 *    - Extract $6.1M profit in ETH
 *
 * Root Causes:
 * - No slippage protection on deposits/withdrawals
 * - Share calculation vulnerable to price manipulation
 * - Missing oracle for true token prices
 * - No time-weighted average price (TWAP) usage
 * - Rebalancing can be triggered during manipulation
 * - No sandwich attack protection
 * - Missing deposit/withdrawal cooldown periods
 *
 * Fix:
 * - Implement TWAP oracles for price checks
 * - Add slippage limits on deposits/withdrawals
 * - Require balanced deposits according to true pool ratio
 * - Add cooldown between deposits and withdrawals
 * - Implement maximum deposit/withdrawal per block
 * - Add circuit breakers for large price movements
 * - Use Chainlink or other external oracles
 * - Implement deposit/withdrawal fees to discourage attacks
 */
