// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * ALPHA HOMORA EXPLOIT (February 2021)
 *
 * Attack Vector: Credit Account Manipulation via Iron Bank Integration
 * Loss: $37 million
 *
 * VULNERABILITY:
 * Alpha Homora V2 integrated with Cream Finance's Iron Bank as a lending
 * protocol. The vulnerability was in how credit accounts were tracked when
 * users borrowed through leveraged yield farming positions.
 *
 * The attacker exploited a flaw in the debt calculation mechanism that
 * allowed them to borrow far more than their collateral was worth by
 * manipulating the share-to-amount conversion in the lending pool.
 *
 * Attack Steps:
 * 1. Open leveraged farming position on Alpha Homora
 * 2. Manipulate sUSD/USDC pool reserves via large swap
 * 3. Exploit debt share calculation to borrow excessive amounts
 * 4. Drain Iron Bank reserves backing the position
 * 5. Profit from overborrowed funds
 */

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface ICErc20 {
    function borrow(uint256 amount) external returns (uint256);

    function borrowBalanceCurrent(address account) external returns (uint256);
}

contract AlphaHomoraBank {
    struct Position {
        address owner;
        uint256 collateral;
        uint256 debtShare;
    }

    mapping(uint256 => Position) public positions;
    uint256 public nextPositionId;

    address public cToken;
    uint256 public totalDebt;
    uint256 public totalDebtShare;

    constructor(address _cToken) {
        cToken = _cToken;
        nextPositionId = 1;
    }

    /**
     * @notice Open a leveraged position
     */
    function openPosition(
        uint256 collateralAmount,
        uint256 borrowAmount
    ) external returns (uint256 positionId) {
        positionId = nextPositionId++;

        positions[positionId] = Position({
            owner: msg.sender,
            collateral: collateralAmount,
            debtShare: 0
        });

        // User provides collateral (simplified)
        // In real Alpha Homora, this would involve LP tokens

        // Borrow from Iron Bank
        _borrow(positionId, borrowAmount);

        return positionId;
    }

    /**
     * @notice VULNERABLE: Borrow function with flawed share calculation
     * @dev Debt shares are calculated incorrectly when totalDebt is manipulated
     */
    function _borrow(uint256 positionId, uint256 amount) internal {
        Position storage pos = positions[positionId];

        // Calculate debt shares for this borrow
        uint256 share;

        if (totalDebtShare == 0) {
            share = amount;
        } else {
            // VULNERABILITY: This calculation is vulnerable when totalDebt
            // has been manipulated via external pool state changes
            share = (amount * totalDebtShare) / totalDebt;
        }

        pos.debtShare += share;
        totalDebtShare += share;
        totalDebt += amount;

        // Borrow from Iron Bank (Cream Finance)
        ICErc20(cToken).borrow(amount);
    }

    /**
     * @notice Repay debt for a position
     */
    function repay(uint256 positionId, uint256 amount) external {
        Position storage pos = positions[positionId];
        require(msg.sender == pos.owner, "Not position owner");

        // Calculate how many shares this repayment covers
        uint256 shareToRemove = (amount * totalDebtShare) / totalDebt;

        require(pos.debtShare >= shareToRemove, "Excessive repayment");

        pos.debtShare -= shareToRemove;
        totalDebtShare -= shareToRemove;
        totalDebt -= amount;

        // Transfer tokens from user (simplified)
    }

    /**
     * @notice Get current debt amount for a position
     * @dev VULNERABLE: Returns debt based on current share ratio
     */
    function getPositionDebt(
        uint256 positionId
    ) external view returns (uint256) {
        Position storage pos = positions[positionId];

        if (totalDebtShare == 0) return 0;

        // Debt calculation based on current share
        // VULNERABILITY: If attacker manipulates totalDebt down, their debt appears smaller
        return (pos.debtShare * totalDebt) / totalDebtShare;
    }

    /**
     * @notice Liquidate an unhealthy position
     */
    function liquidate(uint256 positionId) external {
        Position storage pos = positions[positionId];

        uint256 debt = (pos.debtShare * totalDebt) / totalDebtShare;

        // Check if position is underwater
        // Simplified: collateral should be > 150% of debt
        require(pos.collateral * 100 < debt * 150, "Position is healthy");

        // Liquidate and transfer collateral to liquidator
        pos.collateral = 0;
        pos.debtShare = 0;
    }
}

/**
 * EXPLOIT SCENARIO:
 *
 * Initial State:
 * - Alpha Homora integrated with Iron Bank (Cream)
 * - Users can open leveraged yield farming positions
 * - totalDebt: 100M, totalDebtShare: 100M (1:1 ratio)
 *
 * Attack:
 * 1. Attacker opens initial position:
 *    - Deposits 10 ETH collateral
 *    - Borrows 1M USDC
 *    - Gets debtShare = (1M * 100M) / 100M = 1M shares
 *    - totalDebt now 101M, totalDebtShare 101M
 *
 * 2. Attacker manipulates external pool (sUSD/USDC):
 *    - Uses flash loan to massively imbalance pool
 *    - This affects how Iron Bank calculates borrowed amounts
 *    - Due to integration complexity, totalDebt value becomes stale/incorrect
 *
 * 3. Critical exploitation - opening second position:
 *    - Due to pool manipulation, when calculating new debt shares:
 *    - totalDebt appears much larger than it should be (e.g., 200M instead of 101M)
 *    - Attacker borrows another 10M USDC
 *    - Share calculation: (10M * 101M) / 200M = 5.05M shares
 *    - Should have been: (10M * 101M) / 101M = 10M shares
 *
 * 4. Result:
 *    - Attacker borrowed 11M USDC total
 *    - But only has 6.05M debt shares
 *    - When shares are converted back to debt:
 *      debt = (6.05M * 101M) / 101M = 6.05M
 *    - Attacker appears to owe only 6.05M instead of 11M!
 *
 * 5. Attacker can now:
 *    - Repay the calculated "debt" of 6.05M
 *    - Close position and withdraw collateral
 *    - Keep the difference: 11M - 6.05M = 4.95M profit
 *    - Repeat multiple times to drain $37M
 *
 * Root Cause:
 * - Debt share calculation relied on totalDebt value
 * - totalDebt could be manipulated via external pool state
 * - Share-to-amount conversion was vulnerable to manipulation
 * - Lack of synchronization between Iron Bank and Alpha Homora accounting
 *
 * Fix:
 * - Use time-weighted average for debt calculations
 * - Implement debt ceilings per position
 * - Add manipulation-resistant accounting
 * - Separate internal debt tracking from external pool states
 * - Implement sanity checks on debt share calculations
 */
