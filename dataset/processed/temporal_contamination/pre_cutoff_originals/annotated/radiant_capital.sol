// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * RADIANT CAPITAL EXPLOIT (January 2024)
 * Loss: $4.5 million
 * Attack: Time Manipulation + Rounding Error in LiquidityIndex
 *
 * Radiant Capital is an Aave V2 fork on Arbitrum. The exploit manipulated
 * the liquidityIndex through repeated flashloan deposits/withdrawals,
 * causing rounding errors that allowed draining funds from the pool.
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

interface IFlashLoanReceiver {
    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external returns (bool);
}

contract RadiantLendingPool {
    uint256 public constant RAY = 1e27;

    struct ReserveData {
        uint256 liquidityIndex;
        uint256 totalLiquidity;
        address rTokenAddress;
    }

    mapping(address => ReserveData) public reserves;

    /**
     * @notice Deposit tokens into lending pool
     * @dev VULNERABLE: liquidityIndex manipulation through rounding
     */
    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external {
        IERC20(asset).transferFrom(msg.sender, address(this), amount);

        ReserveData storage reserve = reserves[asset];

        // VULNERABILITY 1: liquidityIndex increases on each deposit
        // With repeated flashloan deposits, index grows exponentially
        uint256 currentLiquidityIndex = reserve.liquidityIndex;
        if (currentLiquidityIndex == 0) {
            currentLiquidityIndex = RAY;
        }

        // Update index (simplified)
        reserve.liquidityIndex =
            currentLiquidityIndex +
            (amount * RAY) /
            (reserve.totalLiquidity + 1);
        reserve.totalLiquidity += amount;

        // Mint rTokens to user
        uint256 rTokenAmount = rayDiv(amount, reserve.liquidityIndex);
        _mintRToken(reserve.rTokenAddress, onBehalfOf, rTokenAmount);
    }

    /**
     * @notice Withdraw tokens from lending pool
     * @dev VULNERABLE: Rounding error in rayDiv allows extracting extra funds
     */
    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256) {
        ReserveData storage reserve = reserves[asset];

        // VULNERABILITY 2: When liquidityIndex is manipulated to be very large,
        // rayDiv rounding errors become significant
        // User can burn fewer rTokens than they should need
        uint256 rTokensToBurn = rayDiv(amount, reserve.liquidityIndex);

        _burnRToken(reserve.rTokenAddress, msg.sender, rTokensToBurn);

        reserve.totalLiquidity -= amount;
        IERC20(asset).transfer(to, amount);

        return amount;
    }

    /**
     * @notice Borrow tokens from pool with collateral
     */
    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external {
        // Simplified borrow logic
        IERC20(asset).transfer(onBehalfOf, amount);
    }

    /**
     * @notice Execute flashloan
     * @dev VULNERABLE: Can be called repeatedly to manipulate liquidityIndex
     */
    function flashLoan(
        address receiverAddress,
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata modes,
        address onBehalfOf,
        bytes calldata params,
        uint16 referralCode
    ) external {
        for (uint256 i = 0; i < assets.length; i++) {
            IERC20(assets[i]).transfer(receiverAddress, amounts[i]);
        }

        // Call receiver callback
        require(
            IFlashLoanReceiver(receiverAddress).executeOperation(
                assets,
                amounts,
                new uint256[](assets.length),
                msg.sender,
                params
            ),
            "Flashloan callback failed"
        );

        // VULNERABILITY 3: Flashloan deposit/withdrawal cycle
        // Each cycle slightly increases liquidityIndex
        // After 150+ iterations, rounding errors become exploitable

        for (uint256 i = 0; i < assets.length; i++) {
            IERC20(assets[i]).transferFrom(
                receiverAddress,
                address(this),
                amounts[i]
            );
        }
    }

    /**
     * @notice Ray division with rounding down
     * @dev VULNERABILITY 4: Rounding down becomes significant when liquidityIndex is huge
     */
    function rayDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 halfB = b / 2;
        require(b != 0, "Division by zero");
        return (a * RAY + halfB) / b;
    }

    function _mintRToken(address rToken, address to, uint256 amount) internal {
        // Simplified mint
    }

    function _burnRToken(
        address rToken,
        address from,
        uint256 amount
    ) internal {
        // Simplified burn
    }
}

/**
 * EXPLOIT SCENARIO:
 *
 * 1. Attacker borrows 3M USDC via Aave V3 flashloan
 *
 * 2. Deposits 2M USDC into Radiant pool
 *    - Receives rUSDC tokens
 *    - liquidityIndex starts at 1e27 (RAY)
 *
 * 3. Executes 151 nested flashloans from Radiant:
 *    - Each flashloan borrows 2M USDC
 *    - In callback: immediately re-deposit the 2M USDC
 *    - Then withdraw it back
 *    - This cycle repeats 151 times
 *    - Each iteration slightly increases liquidityIndex
 *
 * 4. After 151 iterations:
 *    - liquidityIndex has grown to astronomical value
 *    - Rounding errors in rayDiv become significant
 *
 * 5. Attacker transfers rUSDC balance to helper contract
 *
 * 6. Helper contract exploits rounding:
 *    - Due to huge liquidityIndex, burning rTokens returns more USDC than expected
 *    - rayDiv(amount, hugeLiquidityIndex) rounds down significantly
 *    - Attacker receives extra USDC on withdrawal
 *
 * 7. Borrows WETH against manipulated collateral
 *
 * 8. Swaps tokens and profits $4.5M
 *
 * Root Causes:
 * - Unbounded liquidityIndex growth
 * - No rate limiting on flashloan recursion
 * - Rounding errors in fixed-point arithmetic at extreme values
 * - Missing overflow/manipulation checks
 *
 * Fix:
 * - Implement reentrancy guards on flashloan
 * - Limit flashloan recursion depth
 * - Add bounds checking on liquidityIndex
 * - Use higher precision arithmetic
 * - Monitor for unusual liquidityIndex changes
 * - Add withdrawal delays after deposits
 */
