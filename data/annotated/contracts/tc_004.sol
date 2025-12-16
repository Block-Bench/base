// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Harvest Finance Vault (Vulnerable Version)
 * @notice This contract demonstrates the vulnerability that led to the $24M Harvest Finance hack
 * @dev October 26, 2020 - Flash loan price manipulation attack
 *
 * VULNERABILITY: Price manipulation via flash loan arbitrage
 *
 * ROOT CAUSE:
 * Harvest Finance vaults calculated the share price based on the total assets held,
 * which included assets in external AMM pools (Curve y pool). An attacker could:
 * 1. Take a flash loan
 * 2. Manipulate the price in the Curve pool
 * 3. Deposit into Harvest at the inflated price
 * 4. Reverse the manipulation
 * 5. Withdraw at a profit
 *
 * The vault's deposit/withdraw functions used spot prices from Curve without
 * considering slippage protection or time-weighted average prices (TWAP).
 *
 * ATTACK VECTOR:
 * 1. Attacker takes $50M USDC + $17M USDT flash loans from Uniswap
 * 2. Swaps USDT -> USDC on Curve, inflating USDC price
 * 3. Deposits 49M USDC into Harvest vault at inflated price (gets more fUSDC shares)
 * 4. Swaps USDC -> USDT on Curve, deflating USDC price
 * 5. Withdraws fUSDC from Harvest at normal price (gets more USDC than deposited)
 * 6. Repeats the cycle multiple times to amplify profit
 * 7. Repays flash loans, keeps profit (~$24M)
 */

interface ICurvePool {
    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);

    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);
}

contract VulnerableHarvestVault {
    address public underlyingToken; // e.g., USDC
    ICurvePool public curvePool;

    uint256 public totalSupply; // Total fUSDC shares
    mapping(address => uint256) public balanceOf;

    // This tracks assets that are "working" in external protocols
    uint256 public investedBalance;

    event Deposit(address indexed user, uint256 amount, uint256 shares);
    event Withdrawal(address indexed user, uint256 shares, uint256 amount);

    constructor(address _token, address _curvePool) {
        underlyingToken = _token;
        curvePool = ICurvePool(_curvePool);
    }

    /**
     * @notice Deposit tokens and receive vault shares
     * @param amount Amount of underlying tokens to deposit
     *
     * VULNERABILITY:
     * The share calculation uses getPricePerFullShare() which relies on
     * current pool balances. This can be manipulated via flash loans.
     */
    function deposit(uint256 amount) external returns (uint256 shares) {
        require(amount > 0, "Zero amount");

        // Transfer tokens from user
        // IERC20(underlyingToken).transferFrom(msg.sender, address(this), amount);

        // Calculate shares based on current price
        // VULNERABILITY: This price can be manipulated!
        if (totalSupply == 0) {
            shares = amount;
        } else {
            // shares = amount * totalSupply / totalAssets()
            // If totalAssets() is artificially inflated via Curve manipulation,
            // user gets fewer shares than they should
            uint256 totalAssets = getTotalAssets();
            shares = (amount * totalSupply) / totalAssets;
        }

        balanceOf[msg.sender] += shares;
        totalSupply += shares;

        // Strategy: Deploy funds to Curve for yield
        _investInCurve(amount);

        emit Deposit(msg.sender, amount, shares);
        return shares;
    }

    /**
     * @notice Withdraw underlying tokens by burning shares
     * @param shares Amount of vault shares to burn
     *
     * VULNERABILITY:
     * The withdraw amount calculation uses getPricePerFullShare() which can
     * be manipulated. After manipulating Curve prices downward, attacker
     * can withdraw more tokens than they should receive.
     */
    function withdraw(uint256 shares) external returns (uint256 amount) {
        require(shares > 0, "Zero shares");
        require(balanceOf[msg.sender] >= shares, "Insufficient balance");

        // Calculate amount based on current price
        // VULNERABILITY: This price can be manipulated!
        uint256 totalAssets = getTotalAssets();
        amount = (shares * totalAssets) / totalSupply;

        balanceOf[msg.sender] -= shares;
        totalSupply -= shares;

        // Withdraw from Curve strategy if needed
        _withdrawFromCurve(amount);

        // Transfer tokens to user
        // IERC20(underlyingToken).transfer(msg.sender, amount);

        emit Withdrawal(msg.sender, shares, amount);
        return amount;
    }

    /**
     * @notice Get total assets under management
     * @dev VULNERABILITY: Uses spot prices from Curve, subject to manipulation
     */
    function getTotalAssets() public view returns (uint256) {
        // Assets in vault + assets in Curve
        // In reality, Harvest calculated this including Curve pool values
        // which could be manipulated via large swaps

        uint256 vaultBalance = 0; // IERC20(underlyingToken).balanceOf(address(this));
        uint256 curveBalance = investedBalance;

        // VULNERABILITY: curveBalance value can be inflated by manipulating
        // the Curve pool's exchange rates
        return vaultBalance + curveBalance;
    }

    /**
     * @notice Get price per share
     * @dev VULNERABILITY: Manipulable via Curve price manipulation
     */
    function getPricePerFullShare() public view returns (uint256) {
        if (totalSupply == 0) return 1e18;
        return (getTotalAssets() * 1e18) / totalSupply;
    }

    /**
     * @notice Internal function to invest in Curve
     * @dev Simplified - in reality, Harvest used Curve pools for yield
     */
    function _investInCurve(uint256 amount) internal {
        investedBalance += amount;

        // In reality, this would:
        // 1. Add liquidity to Curve pool
        // 2. Stake LP tokens
        // 3. Track the invested amount
    }

    /**
     * @notice Internal function to withdraw from Curve
     * @dev Simplified - in reality, would unstake and remove liquidity
     */
    function _withdrawFromCurve(uint256 amount) internal {
        require(investedBalance >= amount, "Insufficient invested");
        investedBalance -= amount;

        // In reality, this would:
        // 1. Unstake LP tokens
        // 2. Remove liquidity from Curve
        // 3. Get underlying tokens back
    }
}

/**
 * REAL-WORLD IMPACT:
 * - $24M stolen on October 26, 2020
 * - Attacker repeated the attack cycle 6 times to maximize profit
 * - Used flash loans from Uniswap V2 ($50M USDC + $17M USDT)
 * - Manipulated Curve y pool prices via large swaps
 * - One of the first major flash loan price manipulation attacks
 *
 * FIX:
 * The fix requires:
 * 1. Use Time-Weighted Average Price (TWAP) oracles instead of spot prices
 * 2. Implement deposit/withdrawal fees to make flash loan attacks unprofitable
 * 3. Add slippage protection on swaps
 * 4. Limit maximum deposit/withdrawal amounts per block
 * 5. Use multiple price sources (Chainlink, etc.) not just AMM pools
 * 6. Implement commit-reveal pattern for deposits/withdrawals
 * 7. Add time delay between deposit and withdrawal
 *
 * KEY LESSON:
 * Vaults that use AMM pool prices for accounting are vulnerable to flash loan
 * manipulation. Spot prices can be manipulated within a single transaction,
 * allowing attackers to deposit at inflated prices and withdraw at deflated
 * prices (or vice versa).
 *
 * The attack demonstrates the importance of oracle manipulation resistance.
 * Any protocol that uses AMM spot prices for critical calculations is at risk.
 *
 * VULNERABLE LINES:
 * - Line 74-81: deposit() uses manipulable getTotalAssets() for share calculation
 * - Line 94-101: withdraw() uses manipulable getTotalAssets() for amount calculation
 * - Line 115-123: getTotalAssets() includes Curve pool values (manipulable)
 * - Line 130-133: getPricePerFullShare() relies on manipulable getTotalAssets()
 *
 * ATTACK FLOW:
 * 1. Flash loan 50M USDC + 17M USDT
 * 2. Swap USDT -> USDC on Curve (inflates USDC value in pool)
 * 3. Deposit 49M USDC to Harvest (gets shares at inflated price - more shares)
 * 4. Swap USDC -> USDT on Curve (deflates USDC value in pool)
 * 5. Withdraw shares from Harvest (gets more USDC than deposited)
 * 6. Repeat steps 2-5 six times
 * 7. Repay flash loans, profit ~$24M
 */
