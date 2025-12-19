// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Curve Finance Pool (Vulnerable Vyper Version)
 * @notice This contract demonstrates the Vyper reentrancy vulnerability that led to the $70M Curve hack
 * @dev July 30, 2023 - Vyper compiler bug causing reentrancy vulnerability
 *
 * VULNERABILITY: Reentrancy due to Vyper compiler bug
 *
 * ROOT CAUSE:
 * Certain versions of the Vyper compiler (0.2.15, 0.2.16, 0.3.0) had a bug in
 * handling reentrancy guards. The nonreentrant decorator did not properly protect
 * functions when:
 * 1. Multiple nonreentrant functions existed
 * 2. Functions made external calls (like ETH transfers)
 *
 * In Curve pools, the add_liquidity() function:
 * 1. Accepted ETH
 * 2. Transferred ETH to update balances
 * 3. The ETH transfer triggered receive()/fallback() in attacker contract
 * 4. Attacker could call add_liquidity() again during this callback
 * 5. The reentrancy guard failed to prevent this
 *
 * ATTACK VECTOR:
 * 1. Attacker takes flash loan (80,000 ETH from Balancer)
 * 2. Calls add_liquidity() with 40,000 ETH
 * 3. During ETH transfer in add_liquidity(), receive() is triggered
 * 4. In receive(), attacker calls add_liquidity() AGAIN with another 40,000 ETH
 * 5. Pool's internal accounting gets confused - mints LP tokens twice
 * 6. Attacker removes liquidity with inflated LP token balance
 * 7. Extracts more assets than deposited
 * 8. Repays flash loan with profit
 *
 * NOTE: This is a COMPILER BUG, not a logic error. The Solidity version below
 * demonstrates the behavior, but the actual vulnerable code was in Vyper.
 */

contract VulnerableCurvePool {
    // Token balances in the pool
    mapping(uint256 => uint256) public balances; // 0 = ETH, 1 = pETH

    // LP token
    mapping(address => uint256) public lpBalances;
    uint256 public totalLPSupply;

    // Reentrancy guard (VULNERABLE - doesn't work properly like in Vyper bug)
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    event LiquidityAdded(
        address indexed provider,
        uint256[2] amounts,
        uint256 lpMinted
    );
    event LiquidityRemoved(
        address indexed provider,
        uint256 lpBurned,
        uint256[2] amounts
    );

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @notice Add liquidity to the pool
     * @param amounts Array of token amounts to deposit [ETH, pETH]
     * @param min_mint_amount Minimum LP tokens to mint
     *
     * VULNERABILITY:
     * The nonreentrant modifier in Vyper was supposed to prevent reentrancy,
     * but due to a compiler bug, it failed when:
     * 1. Function made external calls (ETH transfer)
     * 2. Multiple nonreentrant functions existed
     *
     * This allowed attackers to call add_liquidity recursively.
     */
    function add_liquidity(
        uint256[2] memory amounts,
        uint256 min_mint_amount
    ) external payable returns (uint256) {
        // VULNERABILITY: Reentrancy guard doesn't work properly (Vyper bug simulation)
        // In the real Vyper code, @nonreentrant decorator was present but ineffective

        require(amounts[0] == msg.value, "ETH amount mismatch");

        // Calculate LP tokens to mint
        uint256 lpToMint;
        if (totalLPSupply == 0) {
            lpToMint = amounts[0] + amounts[1];
        } else {
            // Simplified: real formula is more complex
            uint256 totalValue = balances[0] + balances[1];
            lpToMint = ((amounts[0] + amounts[1]) * totalLPSupply) / totalValue;
        }

        require(lpToMint >= min_mint_amount, "Slippage");

        // Update balances BEFORE external call (following CEI pattern)
        // But Vyper bug allows reentrancy anyway
        balances[0] += amounts[0];
        balances[1] += amounts[1];

        // Mint LP tokens
        lpBalances[msg.sender] += lpToMint;
        totalLPSupply += lpToMint;

        // VULNERABILITY: ETH transfer can trigger reentrancy
        // In Vyper, this line existed and triggered the attacker's receive()
        // The @nonreentrant decorator SHOULD have prevented reentrancy but didn't
        // due to compiler bug
        if (amounts[0] > 0) {
            // Simulate pool's internal operations that involve ETH transfer
            // In reality, Curve pools update internal state during this
            _handleETHTransfer(amounts[0]);
        }

        emit LiquidityAdded(msg.sender, amounts, lpToMint);
        return lpToMint;
    }

    /**
     * @notice Remove liquidity from the pool
     * @param lpAmount Amount of LP tokens to burn
     * @param min_amounts Minimum amounts to receive [ETH, pETH]
     */
    function remove_liquidity(
        uint256 lpAmount,
        uint256[2] memory min_amounts
    ) external {
        require(lpBalances[msg.sender] >= lpAmount, "Insufficient LP");

        // Calculate amounts to return
        uint256 amount0 = (lpAmount * balances[0]) / totalLPSupply;
        uint256 amount1 = (lpAmount * balances[1]) / totalLPSupply;

        require(
            amount0 >= min_amounts[0] && amount1 >= min_amounts[1],
            "Slippage"
        );

        // Burn LP tokens
        lpBalances[msg.sender] -= lpAmount;
        totalLPSupply -= lpAmount;

        // Update balances
        balances[0] -= amount0;
        balances[1] -= amount1;

        // Transfer tokens
        if (amount0 > 0) {
            payable(msg.sender).transfer(amount0);
        }

        uint256[2] memory amounts = [amount0, amount1];
        emit LiquidityRemoved(msg.sender, lpAmount, amounts);
    }

    /**
     * @notice Internal function that handles ETH operations
     * @dev This is where the reentrancy vulnerability is exploited
     */
    function _handleETHTransfer(uint256 amount) internal {
        // In the real Curve Vyper code, operations here triggered reentrancy
        // The Vyper @nonreentrant decorator failed to prevent it

        // Simulate operations that trigger external call
        // In reality, this involved complex pool rebalancing
        (bool success, ) = msg.sender.call{value: 0}("");
        require(success, "Transfer failed");
    }

    /**
     * @notice Exchange tokens (simplified)
     * @param i Index of input token
     * @param j Index of output token
     * @param dx Input amount
     * @param min_dy Minimum output amount
     */
    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external payable returns (uint256) {
        uint256 ui = uint256(int256(i));
        uint256 uj = uint256(int256(j));

        require(ui < 2 && uj < 2 && ui != uj, "Invalid indices");

        // Simplified exchange logic
        uint256 dy = (dx * balances[uj]) / (balances[ui] + dx);
        require(dy >= min_dy, "Slippage");

        if (ui == 0) {
            require(msg.value == dx, "ETH mismatch");
            balances[0] += dx;
        }

        balances[ui] += dx;
        balances[uj] -= dy;

        if (uj == 0) {
            payable(msg.sender).transfer(dy);
        }

        return dy;
    }

    receive() external payable {
        // Attacker's contract would implement receive() to call add_liquidity() again
        // This creates the reentrancy vulnerability
    }
}

/**
 * REAL-WORLD IMPACT:
 * - ~$70M stolen across multiple Curve pools on July 30, 2023
 * - Affected pools: pETH/ETH, msETH/ETH, alETH/ETH, CRV/ETH
 * - Vyper versions 0.2.15, 0.2.16, 0.3.0 were vulnerable
 * - Compiler bug, not a logic error in the contracts themselves
 * - Multiple attackers exploited it within hours
 *
 * VYPER COMPILER BUG DETAILS:
 * The @nonreentrant decorator in Vyper uses a storage variable to track
 * reentrancy state. The bug occurred when:
 * 1. Multiple functions had @nonreentrant decorator
 * 2. The compiler generated incorrect bytecode for the guard
 * 3. The guard checked a different storage slot than it should
 * 4. This allowed reentrancy despite the decorator being present
 *
 * FIX:
 * 1. Upgrade to patched Vyper versions (0.3.1+, 0.2.17+)
 * 2. Recompile all contracts with fixed compiler
 * 3. Redeploy affected pools
 * 4. Add additional reentrancy guards at contract level
 * 5. Follow Checks-Effects-Interactions pattern strictly
 * 6. Minimize external calls in critical functions
 *
 * KEY LESSON:
 * Compiler bugs can introduce vulnerabilities even in well-written code.
 * The Curve contracts followed best practices and used @nonreentrant,
 * but a compiler bug made the protection ineffective.
 *
 * This highlights the importance of:
 * - Compiler audits and verification
 * - Multiple layers of defense (not relying solely on language features)
 * - Careful testing with different compiler versions
 * - Following CEI pattern even when using reentrancy guards
 *
 * VULNERABLE LINES (Conceptual - actual bug was in Vyper compiler):
 * - Line 58-87: add_liquidity() - reentrancy guard failed due to compiler bug
 * - Line 79-84: LP minting happens while contract is still reentrant
 * - Line 88-93: _handleETHTransfer() triggers external call before state finalized
 *
 * ATTACK FLOW:
 * 1. Flash loan 80,000 ETH
 * 2. Call add_liquidity() with 40,000 ETH
 * 3. In receive(), detect reentrancy opportunity
 * 4. Call add_liquidity() AGAIN with another 40,000 ETH (bypassing guard)
 * 5. Pool mints LP tokens twice for overlapping deposits
 * 6. Call remove_liquidity() with inflated LP balance
 * 7. Extract more ETH/pETH than deposited
 * 8. Swap pETH to ETH
 * 9. Repay flash loan with profit
 */
