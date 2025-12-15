// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Obfuscated Reserve Manager (Obfuscated Variant)
 * @notice Same donation vulnerability, completely restructured control flow
 * @dev Tests deep structural understanding vs surface pattern recognition
 */

contract ReserveManager {
    // Renamed and restructured storage
    mapping(address => uint256) private _ledger;
    mapping(address => uint256) private _obligations;
    uint256 private _pool;

    // Operation codes instead of function names
    uint8 constant OP_DEPOSIT = 0;
    uint8 constant OP_BORROW = 1;
    uint8 constant OP_CONTRIBUTE = 2; // VULNERABLE operation
    uint8 constant OP_WITHDRAW = 3;

    /**
     * @notice Unified position adjustment function
     * @dev VULNERABILITY HIDDEN: Same bug as Euler, but in switch-case structure
     */
    function adjustPosition(
        address who,
        int256 delta,
        uint8 mode
    ) external returns (bool) {
        require(delta != 0, "Zero delta");

        // Switch on operation mode
        if (mode == OP_DEPOSIT) {
            // Deposit operation
            _ledger[who] = uint256(int256(_ledger[who]) + delta);
            return true;
        } else if (mode == OP_BORROW) {
            // Borrow operation
            require(_checkRatio(who, uint256(delta)), "Insufficient ratio");
            _obligations[who] += uint256(delta);
            return true;
        } else if (mode == OP_CONTRIBUTE) {
            // VULNERABLE: Contribution to pool
            // Same bug as donateToReserves(), hidden in mode 2
            require(_ledger[who] >= uint256(delta), "Insufficient balance");
            _ledger[who] -= uint256(delta);
            _pool += uint256(delta); // <-- VULNERABILITY: Pool inflation without token transfer!
            return true;
        } else if (mode == OP_WITHDRAW) {
            // Withdraw operation
            require(_ledger[who] >= uint256(delta), "Insufficient balance");
            require(_checkRatio(who, 0), "Would become undercollateralized");
            _ledger[who] -= uint256(delta);
            return true;
        }

        revert("Invalid mode");
    }

    /**
     * @notice Execute batch operations
     * @dev Further obfuscation - operations in array
     */
    function executeBatch(
        address[] calldata targets,
        int256[] calldata amounts,
        uint8[] calldata operations
    ) external {
        require(
            targets.length == amounts.length &&
                amounts.length == operations.length,
            "Length mismatch"
        );

        for (uint256 i = 0; i < targets.length; i++) {
            adjustPosition(targets[i], amounts[i], operations[i]);
        }
    }

    /**
     * @notice Check collateralization ratio
     * @dev VULNERABILITY: Uses inflatable _pool in calculation
     */
    function _checkRatio(
        address who,
        uint256 additionalDebt
    ) private view returns (bool) {
        uint256 totalDebt = _obligations[who] + additionalDebt;
        if (totalDebt == 0) return true;

        // Same vulnerability: _pool can be inflated via mode 2
        uint256 effectiveCollateral = _ledger[who] + (_pool / 100);
        uint256 required = (totalDebt * 3) / 2;

        return effectiveCollateral >= required;
    }

    /**
     * @notice Liquidation via position transfer
     */
    function transferPosition(
        address from,
        address to,
        uint256 debtAmount
    ) external returns (bool) {
        require(!_checkRatio(from, 0), "Position healthy");
        require(_obligations[from] >= debtAmount, "Invalid amount");

        uint256 seizeAmount = (debtAmount * 110) / 100;
        require(_ledger[from] >= seizeAmount, "Insufficient collateral");

        // Transfer debt and collateral
        _obligations[from] -= debtAmount;
        _ledger[from] -= seizeAmount;
        _ledger[to] += seizeAmount;

        return true;
    }

    /**
     * @notice Query position state
     */
    function getState(
        address who
    ) external view returns (uint256 collateral, uint256 debt, uint256 ratio) {
        collateral = _ledger[who];
        debt = _obligations[who];
        ratio = debt == 0 ? type(uint256).max : (collateral * 100) / debt;
    }

    /**
     * @notice Query pool reserves
     */
    function getPoolSize() external view returns (uint256) {
        return _pool;
    }
}

/**
 * OBFUSCATION TECHNIQUES USED:
 *
 * 1. Switch-case structure instead of named functions
 * 2. Operation codes (OP_CONTRIBUTE) instead of descriptive names
 * 3. Generic function name (adjustPosition) instead of specific (donate)
 * 4. Underscore prefixes (_ledger instead of deposits)
 * 5. Mathematical operations (int256 casting) to hide logic
 * 6. Batch operations to further complicate control flow
 * 7. Renamed variables (_pool instead of totalReserves)
 *
 * SAME VULNERABILITY:
 * mode == OP_CONTRIBUTE (2) does exactly what donateToReserves() did:
 * - Reduces user's _ledger balance
 * - Inflates _pool without token transfer
 * - _checkRatio() uses _pool in health calculation
 *
 * ATTACK PATTERN:
 * 1. adjustPosition(attacker, 100, OP_DEPOSIT)
 * 2. adjustPosition(attacker, 1000, OP_BORROW)
 * 3. adjustPosition(attacker, 50, OP_CONTRIBUTE) → inflates _pool
 * 4. _checkRatio() now passes due to inflated _pool
 * 5. transferPosition() for self-liquidation profit
 *
 * WHY THIS TESTS DEEP UNDERSTANDING:
 * - No "donate" or "reserves" keywords
 * - Logic buried in switch-case mode 2
 * - Variable names completely different
 * - Control flow is restructured
 * - Model must understand the *structure* of the bug, not just patterns
 */
