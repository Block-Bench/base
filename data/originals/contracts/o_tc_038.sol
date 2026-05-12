// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * BLUEBERRY PROTOCOL EXPLOIT (February 2024)
 * Loss: $1.4 million
 * Attack: Price Oracle Manipulation + Liquidation Bypass
 *
 * Blueberry Protocol is a leveraged yield farming platform. The exploit involved
 * manipulating collateral valuation through inflated token prices and then draining
 * lending pools by borrowing against the manipulated collateral.
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

interface IPriceOracle {
    function getPrice(address token) external view returns (uint256);
}

contract BlueberryLending {
    struct Market {
        bool isListed;
        uint256 collateralFactor;
        mapping(address => uint256) accountCollateral;
        mapping(address => uint256) accountBorrows;
    }

    mapping(address => Market) public markets;
    IPriceOracle public oracle;

    uint256 public constant COLLATERAL_FACTOR = 75;
    uint256 public constant BASIS_POINTS = 100;

    /**
     * @notice Enter markets to use as collateral
     */
    function enterMarkets(
        address[] calldata vTokens
    ) external returns (uint256[] memory) {
        uint256[] memory results = new uint256[](vTokens.length);
        for (uint256 i = 0; i < vTokens.length; i++) {
            markets[vTokens[i]].isListed = true;
            results[i] = 0;
        }
        return results;
    }

    /**
     * @notice Mint collateral tokens
     * @dev VULNERABLE: Relies on manipulable oracle price
     */
    function mint(address token, uint256 amount) external returns (uint256) {
        IERC20(token).transferFrom(msg.sender, address(this), amount);

        // VULNERABILITY 1: Price from potentially manipulable oracle
        uint256 price = oracle.getPrice(token);

        // VULNERABILITY 2: No validation of price reasonableness
        // No checks for dramatic price changes
        // No TWAP or external price validation

        markets[token].accountCollateral[msg.sender] += amount;
        return 0;
    }

    /**
     * @notice Borrow tokens against collateral
     * @dev VULNERABLE: Borrow calculation uses manipulated collateral values
     */
    function borrow(
        address borrowToken,
        uint256 borrowAmount
    ) external returns (uint256) {
        // VULNERABILITY 3: Calculate collateral value using manipulated prices
        uint256 totalCollateralValue = 0;

        // Sum up all collateral value (would iterate through user's collateral)
        // Using manipulated oracle prices

        uint256 borrowPrice = oracle.getPrice(borrowToken);
        uint256 borrowValue = (borrowAmount * borrowPrice) / 1e18;

        uint256 maxBorrowValue = (totalCollateralValue * COLLATERAL_FACTOR) /
            BASIS_POINTS;

        // VULNERABILITY 4: Allows over-borrowing due to inflated collateral values
        require(borrowValue <= maxBorrowValue, "Insufficient collateral");

        markets[borrowToken].accountBorrows[msg.sender] += borrowAmount;
        IERC20(borrowToken).transfer(msg.sender, borrowAmount);

        return 0;
    }

    /**
     * @notice Liquidate undercollateralized position
     */
    function liquidate(
        address borrower,
        address repayToken,
        uint256 repayAmount,
        address collateralToken
    ) external {
        // Liquidation logic (simplified)
        // Would check if borrower is undercollateralized
        // But vulnerable to same price manipulation issues
    }
}

contract ManipulableOracle is IPriceOracle {
    mapping(address => uint256) public prices;

    /**
     * @notice Get token price
     * @dev VULNERABLE: Price can be manipulated via DEX trades
     */
    function getPrice(address token) external view override returns (uint256) {
        // VULNERABILITY 5: Price derived from low-liquidity DEX pools
        // Attacker can use flashloans to manipulate DEX price
        // Then oracle reads manipulated price
        // No circuit breakers or sanity checks

        return prices[token];
    }

    function setPrice(address token, uint256 price) external {
        prices[token] = price;
    }
}

/**
 * EXPLOIT SCENARIO:
 *
 * 1. Attacker obtains flashloan from Balancer:
 *    - Borrows 1000 WETH
 *
 * 2. Price manipulation phase:
 *    - Target low-liquidity token pairs (e.g., OHM/WETH)
 *    - Execute large buy of OHM using flashloaned WETH
 *    - OHM price artificially inflated on DEX
 *
 * 3. Oracle reads manipulated price:
 *    - Blueberry oracle queries DEX for OHM price
 *    - Reports inflated price (e.g., 2-3x normal)
 *    - No TWAP or external validation
 *
 * 4. Deposit collateral at inflated price:
 *    - Attacker mints bOHM (Blueberry OHM) tokens
 *    - Small amount of OHM now worth much more due to manipulation
 *    - Enter markets to use as collateral
 *
 * 5. Borrow maximum assets:
 *    - Borrow WETH, USDC, WBTC against inflated collateral
 *    - Can borrow far more than real collateral value
 *    - Extract $1.4M worth of assets from lending pools
 *
 * 6. Price restoration:
 *    - Sell OHM back for WETH to restore price
 *    - Repay Balancer flashloan
 *    - Price returns to normal
 *
 * 7. Profit extraction:
 *    - Keep borrowed assets ($1.4M)
 *    - Abandon inflated collateral position
 *    - Position now severely undercollateralized but attacker already extracted value
 *
 * Root Causes:
 * - Oracle reliance on manipulable DEX spot prices
 * - Insufficient liquidity in pricing DEX pools
 * - No Time-Weighted Average Price (TWAP) implementation
 * - Missing external price feed validation (Chainlink)
 * - No circuit breakers for rapid price movements
 * - Lack of price deviation checks between sources
 * - Missing borrow limits during volatile periods
 * - Insufficient collateral liquidation protection
 *
 * Fix:
 * - Implement TWAP oracles with multi-block averaging
 * - Use Chainlink or other external price feeds as primary source
 * - Add minimum liquidity requirements for pricing sources
 * - Implement circuit breakers for >X% price deviation
 * - Add price staleness checks and update frequency limits
 * - Require multiple independent price sources with deviation checks
 * - Implement gradual collateral factor adjustments
 * - Add borrow caps per asset to limit exposure
 * - Implement emergency pause for suspicious price movements
 * - Add liquidation buffer zones and time delays
 */
