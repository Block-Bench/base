// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * PRISMA FINANCE EXPLOIT (March 2024)
 * Loss: $10 million
 * Attack: Delegate Approval Vulnerability in MigrateTroveZap
 *
 * Prisma Finance is a CDP (Collateralized Debt Position) protocol similar to Liquity.
 * The MigrateTroveZap contract had a vulnerability where it accepted user-controlled
 * account parameters in operations, allowing attackers to manipulate other users' troves
 * through delegate approvals.
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

interface IBorrowerOperations {
    function setDelegateApproval(address _delegate, bool _isApproved) external;

    function openTrove(
        address troveManager,
        address account,
        uint256 _maxFeePercentage,
        uint256 _collateralAmount,
        uint256 _debtAmount,
        address _upperHint,
        address _lowerHint
    ) external;

    function closeTrove(address troveManager, address account) external;
}

interface ITroveManager {
    function getTroveCollAndDebt(
        address _borrower
    ) external view returns (uint256 coll, uint256 debt);

    function liquidate(address _borrower) external;
}

contract MigrateTroveZap {
    IBorrowerOperations public borrowerOperations;
    address public wstETH;
    address public mkUSD;

    constructor(address _borrowerOperations, address _wstETH, address _mkUSD) {
        borrowerOperations = _borrowerOperations;
        wstETH = _wstETH;
        mkUSD = _mkUSD;
    }

    /**
     * @notice Migrate trove from one system to another
     * @dev VULNERABLE: User-controlled account parameter
     */
    function openTroveAndMigrate(
        address troveManager,
        address account,
        uint256 maxFeePercentage,
        uint256 collateralAmount,
        uint256 debtAmount,
        address upperHint,
        address lowerHint
    ) external {
        // VULNERABILITY 1: Accepts user-controlled 'account' parameter
        // Attacker can specify another user's address as 'account'
        // If that user previously approved this contract as delegate, it can act on their behalf

        // Transfer collateral from msg.sender
        IERC20(wstETH).transferFrom(
            msg.sender,
            address(this),
            collateralAmount
        );

        // VULNERABILITY 2: Opens trove on behalf of arbitrary 'account' address
        // If victim approved this contract, this call succeeds
        // Opens trove using attacker's collateral but victim's account
        IERC20(wstETH).approve(address(borrowerOperations), collateralAmount);

        borrowerOperations.openTrove(
            troveManager,
            account,
            maxFeePercentage,
            collateralAmount,
            debtAmount,
            upperHint,
            lowerHint
        );

        // VULNERABILITY 3: Transfers minted debt tokens to msg.sender (attacker)
        // Attacker gets the debt tokens while victim's account gets the debt
        IERC20(mkUSD).transfer(msg.sender, debtAmount);
    }

    /**
     * @notice Close a trove for an account
     * @dev VULNERABLE: Can close any account's trove if delegate approved
     */
    function closeTroveFor(address troveManager, address account) external {
        // VULNERABILITY 4: Can close arbitrary account's trove
        // If attacker pays off the debt, they can force close victim's trove
        // And extract the collateral

        borrowerOperations.closeTrove(troveManager, account);
    }
}

contract BorrowerOperations {
    mapping(address => mapping(address => bool)) public delegates;
    ITroveManager public troveManager;

    /**
     * @notice Set delegate approval
     * @dev Users can approve contracts to act on their behalf
     */
    function setDelegateApproval(address _delegate, bool _isApproved) external {
        delegates[msg.sender][_delegate] = _isApproved;
    }

    /**
     * @notice Open a new trove
     * @dev VULNERABLE: No check if msg.sender == account when delegate is approved
     */
    function openTrove(
        address _troveManager,
        address account,
        uint256 _maxFeePercentage,
        uint256 _collateralAmount,
        uint256 _debtAmount,
        address _upperHint,
        address _lowerHint
    ) external {
        // VULNERABILITY 5: Insufficient authorization check
        // Only checks if msg.sender is approved delegate
        // Doesn't validate that delegate should be able to open troves on behalf of account
        require(
            msg.sender == account || delegates[account][msg.sender],
            "Not authorized"
        );

        // Open trove logic (simplified)
        // Creates debt position for 'account' with provided collateral
    }

    /**
     * @notice Close a trove
     */
    function closeTrove(address _troveManager, address account) external {
        require(
            msg.sender == account || delegates[account][msg.sender],
            "Not authorized"
        );

        // Close trove logic (simplified)
    }
}

/**
 * EXPLOIT SCENARIO:
 *
 * 1. Attacker identifies victims who approved MigrateTroveZap as delegate:
 *    - Many users approved zap contracts for convenience
 *    - These approvals were intended for legitimate migrations
 *
 * 2. Attacker obtains flashloan (~1800 wstETH):
 *    - Borrows collateral to fund the attack
 *
 * 3. Attacker calls openTroveAndMigrate():
 *    - Passes victim's address as 'account' parameter
 *    - Provides attacker's collateral (from flashloan)
 *    - Mints maximum debt (mkUSD) against victim's account
 *
 * 4. Zap contract opens trove on victim's behalf:
 *    - Uses delegate approval to authorize the operation
 *    - Opens trove with attacker's collateral but victim's account
 *    - Mints debt tokens to attacker (msg.sender)
 *
 * 5. Attacker receives minted debt tokens:
 *    - Gets full amount of mkUSD (debt tokens)
 *    - Victim's account now has debt obligation
 *
 * 6. Attacker closes their own position:
 *    - Can pay off debt or manipulate price to liquidate
 *    - Extracts collateral if profitable
 *
 * 7. Repeat for multiple victims:
 *    - Drain $10M across multiple accounts
 *    - Repay flashloan with profits
 *
 * Root Causes:
 * - User-controlled account parameter in zap contract
 * - Overly permissive delegate approval system
 * - No distinction between different types of delegate permissions
 * - Missing msg.sender validation for sensitive operations
 * - Zap contract had unnecessary privileges
 * - No time-bounded or scope-limited approvals
 *
 * Fix:
 * - Always validate account == msg.sender for critical operations
 * - Implement granular permission system (specific operation approvals)
 * - Add time-bounded approvals with expiration
 * - Scope delegate permissions to specific operations
 * - Require explicit confirmation for debt-creating operations
 * - Implement maximum debt limits per delegation
 * - Add circuit breakers for unusual delegation patterns
 * - Revoke all existing delegate approvals and require re-approval
 */
