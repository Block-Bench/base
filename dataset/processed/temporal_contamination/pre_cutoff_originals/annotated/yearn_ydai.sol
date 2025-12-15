// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Yearn yDAI Vault - Flash Loan Curve Pool Manipulation
 * @notice This contract demonstrates the vulnerability that led to the Yearn yDAI hack
 * @dev February 4, 2021 - $11M stolen through Curve pool manipulation
 *
 * VULNERABILITY: Using spot price from manipulable Curve pool for vault strategy
 *
 * ROOT CAUSE:
 * The earn() function deposits assets into Curve pool and uses the pool's
 * current virtual price to calculate strategy outcomes. An attacker can
 * use flash loans to temporarily imbalance the Curve pool, inflating the
 * virtual price, which tricks the vault into thinking it has more value
 * than it actually does.
 *
 * ATTACK VECTOR:
 * 1. Flash loan large amount of DAI, USDT, USDC
 * 2. Add liquidity to Curve 3pool with imbalanced amounts (mostly DAI)
 * 3. This inflates Curve's virtual_price temporarily
 * 4. Deposit into yDAI vault and call earn()
 * 5. earn() calculates value using inflated virtual_price
 * 6. Remove liquidity from Curve in imbalanced way (extract USDT)
 * 7. Add it back to normalize pool
 * 8. Repeat process, siphoning value from vault
 * 9. Withdraw from vault with inflated shares
 * 10. Repay flash loan and profit
 *
 * The vulnerability exploits the trust in Curve's virtual_price as a reliable
 * value oracle when it can be manipulated within a single transaction.
 */

interface ICurve3Pool {
    function add_liquidity(
        uint256[3] memory amounts,
        uint256 min_mint_amount
    ) external;

    function remove_liquidity_imbalance(
        uint256[3] memory amounts,
        uint256 max_burn_amount
    ) external;

    function get_virtual_price() external view returns (uint256);
}

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

contract VulnerableYearnVault {
    IERC20 public dai;
    IERC20 public crv3; // Curve 3pool LP token
    ICurve3Pool public curve3Pool;

    mapping(address => uint256) public shares;
    uint256 public totalShares;
    uint256 public totalDeposits;

    uint256 public constant MIN_EARN_THRESHOLD = 1000 ether;

    constructor(address _dai, address _crv3, address _curve3Pool) {
        dai = IERC20(_dai);
        crv3 = IERC20(_crv3);
        curve3Pool = ICurve3Pool(_curve3Pool);
    }

    /**
     * @notice Deposit DAI into the vault
     */
    function deposit(uint256 amount) external {
        dai.transferFrom(msg.sender, address(this), amount);

        uint256 shareAmount;
        if (totalShares == 0) {
            shareAmount = amount;
        } else {
            // Calculate shares based on current vault value
            shareAmount = (amount * totalShares) / totalDeposits;
        }

        shares[msg.sender] += shareAmount;
        totalShares += shareAmount;
        totalDeposits += amount;
    }

    /**
     * @notice Execute vault strategy - deposit into Curve
     *
     * VULNERABILITY IS HERE:
     * The function uses Curve's get_virtual_price() to calculate strategy value.
     * This price can be manipulated through flash loan attacks that temporarily
     * imbalance the Curve pool.
     *
     * Vulnerable sequence:
     * 1. Check if vault has enough idle DAI (line 103)
     * 2. Get Curve virtual price (line 106) <- MANIPULABLE
     * 3. Add liquidity to Curve (line 109-111)
     * 4. Calculate expected LP tokens based on manipulated price
     * 5. Vault thinks it gained more value than it actually did
     *
     * Attacker exploits this by:
     * - Imbalancing Curve pool with flash loan
     * - Calling earn() while pool is imbalanced
     * - Vault uses inflated virtual_price
     * - Restoring pool balance
     * - Repeating to drain vault
     */
    function earn() external {
        uint256 vaultBalance = dai.balanceOf(address(this));
        require(
            vaultBalance >= MIN_EARN_THRESHOLD,
            "Insufficient balance to earn"
        );

        // VULNERABLE: Using manipulable Curve virtual price
        uint256 virtualPrice = curve3Pool.get_virtual_price();

        // Add all DAI to Curve pool
        dai.approve(address(curve3Pool), vaultBalance);
        uint256[3] memory amounts = [vaultBalance, 0, 0]; // Only DAI
        curve3Pool.add_liquidity(amounts, 0);

        // The vault now thinks it has value based on the manipulated virtual price
        // If virtual_price is inflated, vault overestimates its holdings
    }

    /**
     * @notice Withdraw shares from vault
     */
    function withdrawAll() external {
        uint256 userShares = shares[msg.sender];
        require(userShares > 0, "No shares");

        // Calculate withdrawal amount based on current total value
        uint256 withdrawAmount = (userShares * totalDeposits) / totalShares;

        shares[msg.sender] = 0;
        totalShares -= userShares;
        totalDeposits -= withdrawAmount;

        dai.transfer(msg.sender, withdrawAmount);
    }

    /**
     * @notice Get vault's total value including Curve position
     */
    function balance() public view returns (uint256) {
        return
            dai.balanceOf(address(this)) +
            (crv3.balanceOf(address(this)) * curve3Pool.get_virtual_price()) /
            1e18;
    }
}

/**
 * Example attack flow:
 *
 * 1. Flash loan 100M DAI, 50M USDT, 50M USDC
 * 2. Add liquidity to Curve 3pool: [100M DAI, 50M USDC, 0 USDT]
 *    - This imbalances the pool and inflates virtual_price
 * 3. Deposit 1M DAI into yDAI vault
 * 4. Call vault.earn()
 *    - Vault uses inflated virtual_price to value position
 * 5. Remove liquidity from Curve imbalanced: [0, 0, 50M USDT]
 *    - Extract USDT, leaving pool imbalanced the other way
 * 6. Add liquidity back to normalize: [0, 0, 50M USDT]
 * 7. Repeat steps 2-6 multiple times
 *    - Each iteration siphons value from vault
 * 8. Withdraw from vault with inflated share value
 * 9. Repay flash loans, keep profit
 *
 * REAL-WORLD IMPACT:
 * - $11M stolen in February 2021
 * - Exploited Curve pool manipulation via flash loans
 * - Led to improved oracle designs in DeFi
 * - Yearn updated strategy to use TWAP instead of spot price
 *
 * FIX:
 * 1. Use Time-Weighted Average Price (TWAP) instead of spot price
 * 2. Implement slippage checks on Curve operations
 * 3. Use multiple price oracles and sanity checks
 * 4. Limit strategy execution frequency
 *
 * function earn() external {
 *     uint256 vaultBalance = dai.balanceOf(address(this));
 *     require(vaultBalance >= MIN_EARN_THRESHOLD, "Insufficient");
 *
 *     // FIX: Use TWAP oracle instead of spot price
 *     uint256 expectedPrice = twapOracle.getPrice();
 *     uint256 currentPrice = curve3Pool.get_virtual_price();
 *
 *     // Sanity check: current price shouldn't deviate too much from TWAP
 *     require(
 *         currentPrice <= expectedPrice * 102 / 100 &&
 *         currentPrice >= expectedPrice * 98 / 100,
 *         "Price manipulation detected"
 *     );
 *
 *     dai.approve(address(curve3Pool), vaultBalance);
 *     uint256[3] memory amounts = [vaultBalance, 0, 0];
 *
 *     // Add minimum slippage protection
 *     uint256 minLPTokens = (vaultBalance * 1e18) / expectedPrice * 99 / 100;
 *     curve3Pool.add_liquidity(amounts, minLPTokens);
 * }
 *
 * VULNERABLE LINES:
 * - Line 106: get_virtual_price() returns manipulable spot price
 * - Line 109-111: Adding liquidity using manipulated price for calculations
 * - Line 142: balance() also uses manipulable virtual_price
 *
 * KEY LESSON:
 * Never trust spot prices from AMM pools for critical calculations.
 * They can be manipulated within a single transaction using flash loans.
 * Always use TWAP oracles or multiple price sources with sanity checks.
 * Flash loan attacks can temporarily distort any spot price mechanism.
 */
