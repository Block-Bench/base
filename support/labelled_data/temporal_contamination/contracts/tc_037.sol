// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * UWU LEND EXPLOIT (June 2024)
 * Loss: $19.3 million
 * Attack: Oracle Price Manipulation via Curve Pool Manipulation
 *
 * UwU Lend is an Aave V2 fork lending protocol. The exploit involved manipulating
 * the price oracle for sUSDE (staked USDe) by draining liquidity from Curve pools,
 * causing the oracle to report incorrect prices, then borrowing against inflated collateral.
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

interface IAaveOracle {
    function getAssetPrice(address asset) external view returns (uint256);

    function setAssetSources(
        address[] calldata assets,
        address[] calldata sources
    ) external;
}

interface ICurvePool {
    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);

    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);

    function balances(uint256 i) external view returns (uint256);
}

interface ILendingPool {
    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;

    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);
}

contract UwuLendingPool is ILendingPool {
    IAaveOracle public oracle;
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;
    uint256 public constant LTV = 8500;
    uint256 public constant BASIS_POINTS = 10000;

    /**
     * @notice Deposit collateral into pool
     */
    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external override {
        IERC20(asset).transferFrom(msg.sender, address(this), amount);
        deposits[onBehalfOf] += amount;
    }

    /**
     * @notice Borrow assets from pool
     * @dev VULNERABLE: Uses manipulable oracle price
     */
    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external override {
        // VULNERABILITY 1: Oracle price can be manipulated via Curve pool drainage
        uint256 collateralPrice = oracle.getAssetPrice(msg.sender);
        uint256 borrowPrice = oracle.getAssetPrice(asset);

        // VULNERABILITY 2: No price freshness check
        // No validation if price has changed dramatically
        // No circuit breaker for unusual price movements

        uint256 collateralValue = (deposits[msg.sender] * collateralPrice) /
            1e18;
        uint256 maxBorrow = (collateralValue * LTV) / BASIS_POINTS;

        uint256 borrowValue = (amount * borrowPrice) / 1e18;

        // VULNERABILITY 3: Health factor calculated with manipulated price
        require(borrowValue <= maxBorrow, "Insufficient collateral");

        borrows[msg.sender] += amount;
        IERC20(asset).transfer(onBehalfOf, amount);
    }

    /**
     * @notice Withdraw collateral
     */
    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external override returns (uint256) {
        require(deposits[msg.sender] >= amount, "Insufficient balance");
        deposits[msg.sender] -= amount;
        IERC20(asset).transfer(to, amount);
        return amount;
    }
}

contract CurveOracle {
    ICurvePool public curvePool;

    constructor(address _pool) {
        curvePool = _pool;
    }

    /**
     * @notice Get asset price from Curve pool
     * @dev VULNERABLE: Price derived from manipulable Curve pool
     */
    function getAssetPrice(address asset) external view returns (uint256) {
        // VULNERABILITY 4: Price based on Curve pool state
        // Attacker can drain pool to manipulate price
        // No TWAP (Time-Weighted Average Price)
        // No external price validation

        uint256 balance0 = curvePool.balances(0);
        uint256 balance1 = curvePool.balances(1);

        // VULNERABILITY 5: Spot price calculation
        // Easily manipulated by large swaps or liquidity removal
        uint256 price = (balance1 * 1e18) / balance0;

        return price;
    }
}

/**
 * EXPLOIT SCENARIO:
 *
 * 1. Attacker obtains massive flashloans:
 *    - Borrows from Aave V3, Balancer, Spark, MorphoBlue, MakerDAO
 *    - Total: Billions in stablecoins and ETH
 *
 * 2. Price manipulation phase - drain Curve pools:
 *    - Target: sUSDE/USDe, USDe/DAI, USDe/crvUSD pools
 *    - Execute large swaps to remove USDe liquidity
 *    - Imbalance the pools to inflate sUSDE price
 *
 * 3. Oracle reports manipulated price:
 *    - UwU Lend oracle reads from manipulated Curve pools
 *    - sUSDE price artificially inflated (e.g., 2x real value)
 *    - No TWAP or external validation to detect manipulation
 *
 * 4. Deposit collateral into UwU Lend:
 *    - Deposit sUSDE at inflated price
 *    - Collateral appears worth 2x real value
 *    - Health factor calculated with manipulated price
 *
 * 5. Borrow maximum assets:
 *    - Borrow WETH, DAI, USDC, WBTC at 85% LTV
 *    - Can borrow 1.7x actual collateral value due to manipulation
 *    - Extract $19.3M worth of assets
 *
 * 6. Price restoration:
 *    - Reverse swaps in Curve pools
 *    - Price returns to normal
 *    - Attacker's position now undercollateralized
 *
 * 7. Profit extraction:
 *    - Keep borrowed assets ($19.3M)
 *    - Abandon collateral position
 *    - Repay flashloans with profits
 *
 * Root Causes:
 * - Oracle reliance on manipulable Curve pool prices
 * - No Time-Weighted Average Price (TWAP) implementation
 * - Lack of external price feed validation (Chainlink, etc.)
 * - No circuit breakers for dramatic price movements
 * - Insufficient liquidity in Curve pools for price stability
 * - No borrow caps or limits during volatile periods
 * - Missing price deviation checks between sources
 *
 * Fix:
 * - Implement TWAP oracles (multi-block price averaging)
 * - Use Chainlink or other external price feeds as primary source
 * - Add deviation checks between multiple price sources
 * - Implement circuit breakers for >X% price movement
 * - Add borrow caps that limit exposure during volatility
 * - Require minimum liquidity depth in pricing pools
 * - Implement gradual price updates, not instant spot prices
 * - Add emergency pause functionality for suspicious activity
 */
