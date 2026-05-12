// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Cream Finance Lending Pool (Vulnerable Version)
 * @notice This contract demonstrates the vulnerability that led to the $130M Cream Finance hack
 * @dev October 27, 2021 - Complex flash loan + price oracle manipulation
 *
 * VULNERABILITY: Price oracle manipulation + flash loan + reentrancy
 *
 * ROOT CAUSE:
 * Cream Finance was a fork of Compound Finance with similar mechanics:
 * - Users deposit collateral to mint crTokens
 * - crTokens can be used as collateral to borrow other assets
 * - Borrowing power based on collateral value (from price oracles)
 *
 * The attack exploited:
 * 1. Cream used yUSD token as collateral
 * 2. yUSD price was calculated from its underlying assets (via Curve pool)
 * 3. Attacker could manipulate yUSD price by draining Curve pool
 * 4. With inflated yUSD value, attacker could borrow massive amounts
 *
 * ATTACK VECTOR:
 * 1. Flash loan $500M DAI from MakerDAO
 * 2. Convert DAI to yUSD (via Curve), mint crYUSD as collateral ($500M value)
 * 3. Flash loan 524,000 ETH from Aave
 * 4. Mint crETH as additional collateral ($2B value)
 * 5. Borrow yUSD multiple times against ETH collateral
 * 6. Withdraw yUSD from Curve to underlying tokens, doubling crYUSD price
 * 7. Now crYUSD collateral is valued at $1.5B (was $500M)
 * 8. Borrow massive amounts against inflated collateral
 * 9. Repay flash loans, keep profit
 */

interface IOracle {
    function getUnderlyingPrice(address cToken) external view returns (uint256);
}

interface ICToken {
    function mint(uint256 mintAmount) external;

    function borrow(uint256 borrowAmount) external;

    function redeem(uint256 redeemTokens) external;

    function underlying() external view returns (address);
}

contract VulnerableCreamLending {
    // Oracle for getting asset prices
    IOracle public oracle;

    // Collateral factors (how much can be borrowed against collateral)
    mapping(address => uint256) public collateralFactors; // e.g., 75% = 0.75e18

    // User deposits (crToken balances)
    mapping(address => mapping(address => uint256)) public userDeposits;

    // User borrows
    mapping(address => mapping(address => uint256)) public userBorrows;

    // Supported markets
    mapping(address => bool) public supportedMarkets;

    event Deposit(address indexed user, address indexed cToken, uint256 amount);
    event Borrow(address indexed user, address indexed cToken, uint256 amount);

    constructor(address _oracle) {
        oracle = IOracle(_oracle);
    }

    /**
     * @notice Mint crTokens by depositing underlying assets
     * @param cToken The crToken to mint
     * @param amount Amount of underlying to deposit
     *
     * This function is safe, but sets up the collateral that enables the attack
     */
    function mint(address cToken, uint256 amount) external {
        require(supportedMarkets[cToken], "Market not supported");

        // Transfer underlying from user (simplified)
        // address underlying = ICToken(cToken).underlying();
        // IERC20(underlying).transferFrom(msg.sender, address(this), amount);

        // Mint crTokens to user
        userDeposits[msg.sender][cToken] += amount;

        emit Deposit(msg.sender, cToken, amount);
    }

    /**
     * @notice Borrow assets against collateral
     * @param cToken The crToken to borrow
     * @param amount Amount to borrow
     *
     * VULNERABILITY:
     * The borrowing limit is calculated based on oracle prices.
     * If the oracle price can be manipulated (as with yUSD via Curve),
     * attackers can borrow far more than their actual collateral is worth.
     */
    function borrow(address cToken, uint256 amount) external {
        require(supportedMarkets[cToken], "Market not supported");

        // Calculate user's borrowing power
        uint256 borrowPower = calculateBorrowPower(msg.sender);

        // Calculate current total borrows value
        uint256 currentBorrows = calculateTotalBorrows(msg.sender);

        // Get value of new borrow
        // VULNERABILITY: Uses oracle price which can be manipulated!
        uint256 borrowValue = (oracle.getUnderlyingPrice(cToken) * amount) /
            1e18;

        // Check if user has enough collateral
        require(
            currentBorrows + borrowValue <= borrowPower,
            "Insufficient collateral"
        );

        // Update borrow balance
        userBorrows[msg.sender][cToken] += amount;

        // Transfer tokens to borrower (simplified)
        // address underlying = ICToken(cToken).underlying();
        // IERC20(underlying).transfer(msg.sender, amount);

        emit Borrow(msg.sender, cToken, amount);
    }

    /**
     * @notice Calculate user's total borrowing power
     * @param user The user address
     * @return Total borrowing power in USD (scaled by 1e18)
     *
     * VULNERABILITY:
     * This function uses oracle.getUnderlyingPrice() which can return
     * manipulated prices for tokens like yUSD.
     *
     * In the Cream hack:
     * 1. Attacker deposited crYUSD (backed by Curve pool)
     * 2. Oracle valued yUSD based on its underlying assets
     * 3. Attacker manipulated Curve pool by withdrawing all yUSD
     * 4. This made remaining yUSD appear more valuable
     * 5. Oracle reported inflated price
     * 6. Attacker could borrow huge amounts
     */
    function calculateBorrowPower(address user) public view returns (uint256) {
        uint256 totalPower = 0;

        // Iterate through all supported markets (simplified)
        // In reality, would track user's entered markets
        address[] memory markets = new address[](2); // Placeholder

        for (uint256 i = 0; i < markets.length; i++) {
            address cToken = markets[i];
            uint256 balance = userDeposits[user][cToken];

            if (balance > 0) {
                // Get price from oracle
                // VULNERABILITY: This price can be manipulated!
                uint256 price = oracle.getUnderlyingPrice(cToken);

                // Calculate value
                uint256 value = (balance * price) / 1e18;

                // Apply collateral factor
                uint256 power = (value * collateralFactors[cToken]) / 1e18;

                totalPower += power;
            }
        }

        return totalPower;
    }

    /**
     * @notice Calculate user's total borrow value
     * @param user The user address
     * @return Total borrow value in USD (scaled by 1e18)
     */
    function calculateTotalBorrows(address user) public view returns (uint256) {
        uint256 totalBorrows = 0;

        // Iterate through all supported markets (simplified)
        address[] memory markets = new address[](2); // Placeholder

        for (uint256 i = 0; i < markets.length; i++) {
            address cToken = markets[i];
            uint256 borrowed = userBorrows[user][cToken];

            if (borrowed > 0) {
                uint256 price = oracle.getUnderlyingPrice(cToken);
                uint256 value = (borrowed * price) / 1e18;
                totalBorrows += value;
            }
        }

        return totalBorrows;
    }

    /**
     * @notice Add a supported market
     * @param cToken The crToken to add
     * @param collateralFactor The collateral factor (e.g., 0.75e18 for 75%)
     */
    function addMarket(address cToken, uint256 collateralFactor) external {
        supportedMarkets[cToken] = true;
        collateralFactors[cToken] = collateralFactor;
    }
}

/**
 * REAL-WORLD IMPACT:
 * - $130M stolen on October 27, 2021
 * - Complex multi-step attack using two flash loans
 * - Exploited price oracle manipulation via Curve pool
 * - One of Cream's multiple hacks (they were exploited several times)
 *
 * ATTACK FLOW (Simplified):
 * 1. Flash loan $500M DAI from MakerDAO
 * 2. Swap DAI -> yUSD, deposit to Cream, get crYUSD collateral
 * 3. Flash loan 524,000 ETH from Aave
 * 4. Deposit ETH to Cream, get crETH collateral
 * 5. Borrow yUSD against ETH collateral (multiple times)
 * 6. Withdraw yUSD from Curve to underlying tokens
 * 7. This manipulation doubles the price of remaining yUSD
 * 8. Oracle reports inflated yUSD price
 * 9. Attacker's crYUSD collateral is now valued at $1.5B (was $500M)
 * 10. Borrow massive amounts against inflated collateral
 * 11. Repay flash loans with profit
 *
 * FIX:
 * The fix requires:
 * 1. Use Time-Weighted Average Price (TWAP) oracles
 * 2. Use Chainlink or other manipulation-resistant oracles
 * 3. Don't use LP token prices directly from AMM pools
 * 4. Implement price sanity checks and circuit breakers
 * 5. Add borrow caps per market
 * 6. Implement gradual price updates, not instant changes
 * 7. Use multiple oracle sources and take median
 * 8. Add flash loan attack detection
 *
 * KEY LESSON:
 * Oracle manipulation is one of the most dangerous vulnerabilities in DeFi.
 * Using spot prices from AMM pools is especially risky because:
 * - Pools can be manipulated via flash loans
 * - Especially dangerous for low-liquidity assets
 * - Can lead to cascading liquidations and protocol insolvency
 *
 * Cream was particularly vulnerable because:
 * - It listed many low-liquidity tokens
 * - Used Curve pool prices without sufficient safeguards
 * - Allowed recursive borrowing that amplified the attack
 *
 * VULNERABLE LINES:
 * - Line 91-96: borrow() uses manipulable oracle price
 * - Line 116-138: calculateBorrowPower() relies on oracle.getUnderlyingPrice()
 * - Line 128: oracle.getUnderlyingPrice() returns manipulated price
 *
 * The vulnerability is in the ORACLE, not this contract's logic.
 * But the contract should have protected against oracle manipulation.
 */
