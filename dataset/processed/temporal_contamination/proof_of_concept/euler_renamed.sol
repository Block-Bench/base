// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title DefiBank Liquidity Pool (Renamed Variant)
 * @notice Renamed version of donation attack vulnerability
 * @dev VULNERABLE CONTRACT - Same bug, different names
 */

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DefiLiquidityVault {
    IERC20 public immutable baseAsset;

    // Account ledgers
    mapping(address => uint256) public collateralShares; // Renamed from deposits
    mapping(address => uint256) public debtShares; // Renamed from borrowed

    // Protocol accounting
    uint256 public protocolTreasury; // Renamed from totalReserves
    uint256 public aggregateCollateral; // Renamed from totalDeposits
    uint256 public aggregateDebt; // Renamed from totalBorrowed

    constructor(address _asset) {
        baseAsset = IERC20(_asset);
    }

    /**
     * @notice Add collateral to account
     */
    function addCollateral(uint256 qty) external {
        require(qty > 0, "Zero quantity");
        baseAsset.transferFrom(msg.sender, address(this), qty);

        collateralShares[msg.sender] += qty;
        aggregateCollateral += qty;
    }

    /**
     * @notice Take loan against collateral
     */
    function takeLoan(uint256 qty) external {
        require(qty > 0, "Zero quantity");
        require(checkSolvency(msg.sender, qty), "Insufficient backing");

        debtShares[msg.sender] += qty;
        aggregateDebt += qty;
        baseAsset.transfer(msg.sender, qty);
    }

    /**
     * @notice Repay outstanding loan
     */
    function repayLoan(uint256 qty) external {
        require(qty > 0, "Zero quantity");
        require(debtShares[msg.sender] >= qty, "Repayment exceeds debt");

        baseAsset.transferFrom(msg.sender, address(this), qty);
        debtShares[msg.sender] -= qty;
        aggregateDebt -= qty;
    }

    /**
     * @notice VULNERABLE: Contribute shares to protocol treasury
     * @dev Same vulnerability with renamed functions!
     */
    function contributeToTreasury(uint256 qty) external {
        require(collateralShares[msg.sender] >= qty, "Insufficient shares");

        // VULNERABILITY: Burns shares but inflates treasury at face value
        collateralShares[msg.sender] -= qty;
        aggregateCollateral -= qty;
        protocolTreasury += qty; // <-- Same vulnerability, different name!

        // No underlying asset movement!
    }

    /**
     * @notice Remove collateral from account
     */
    function removeCollateral(uint256 qty) external {
        require(collateralShares[msg.sender] >= qty, "Insufficient shares");
        require(checkSolvency(msg.sender, 0), "Position underwater");

        collateralShares[msg.sender] -= qty;
        aggregateCollateral -= qty;
        baseAsset.transfer(msg.sender, qty);
    }

    /**
     * @notice Liquidate underwater position
     */
    function liquidateAccount(address target, uint256 repayQty) external {
        require(!checkSolvency(target, 0), "Account is solvent");
        require(debtShares[target] >= repayQty, "Invalid repayment");

        uint256 seizeQty = (repayQty * 110) / 100;
        require(collateralShares[target] >= seizeQty, "Insufficient backing");

        baseAsset.transferFrom(msg.sender, address(this), repayQty);

        debtShares[target] -= repayQty;
        aggregateDebt -= repayQty;

        collateralShares[target] -= seizeQty;
        collateralShares[msg.sender] += seizeQty;
    }

    /**
     * @notice Verify account solvency
     * @dev Uses inflated treasury in calculation - same vulnerability!
     */
    function checkSolvency(
        address account,
        uint256 extraDebt
    ) internal view returns (bool) {
        uint256 totalLiability = debtShares[account] + extraDebt;
        if (totalLiability == 0) return true;

        // VULNERABILITY: Uses protocolTreasury which can be manipulated
        uint256 backingValue = collateralShares[account] +
            (protocolTreasury / 100);
        uint256 minimumBacking = (totalLiability * 150) / 100;

        return backingValue >= minimumBacking;
    }

    /**
     * @notice Calculate account health ratio
     */
    function calculateHealthRatio(
        address account
    ) external view returns (uint256) {
        if (debtShares[account] == 0) return type(uint256).max;

        uint256 backingValue = collateralShares[account] +
            (protocolTreasury / 100);
        return (backingValue * 100) / debtShares[account];
    }
}

/**
 * ATTACK REMAINS IDENTICAL:
 *
 * 1. Attacker calls addCollateral(20M)
 * 2. Attacker calls takeLoan(200M) - over-leveraged
 * 3. Attacker calls repayLoan(10M)
 * 4. Attacker calls takeLoan(200M) again
 * 5. **EXPLOIT**: Attacker calls contributeToTreasury(100M)
 *    - Inflates protocolTreasury
 *    - Improves health ratio artificially
 * 6. Self-liquidation for profit
 *
 * Same vulnerability, just renamed everything!
 */
