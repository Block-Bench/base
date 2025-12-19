// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * COW PROTOCOL EXPLOIT (November 2024)
 * Loss: $166,000
 * Attack: Unauthorized Callback Invocation + Solver Manipulation
 *
 * CoW Protocol is a DEX aggregator using intent-based trading with solvers.
 * The exploit involved directly calling the uniswapV3SwapCallback function
 * with crafted parameters, bypassing normal swap validation, and extracting
 * funds from a solver contract.
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

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256 amount) external;

    function balanceOf(address account) external view returns (uint256);
}

contract CowSolver {
    IWETH public immutable WETH;
    address public immutable settlement;

    constructor(address _weth, address _settlement) {
        WETH = IWETH(_weth);
        settlement = _settlement;
    }

    /**
     * @notice Uniswap V3 swap callback
     * @dev VULNERABILITY: Can be called directly by anyone, not just Uniswap pool
     */
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external payable {
        // VULNERABILITY 1: No validation that msg.sender is a legitimate Uniswap V3 pool
        // Anyone can call this function directly with arbitrary parameters
        // Should verify: require(msg.sender == expectedPool, "Unauthorized callback");

        // Decode callback data
        (
            uint256 price,
            address solver,
            address tokenIn,
            address recipient
        ) = abi.decode(data, (uint256, address, address, address));

        // VULNERABILITY 2: Trusts user-provided 'solver' address in calldata
        // Attacker can specify their own address as solver
        // Contract will transfer tokens to attacker-controlled address

        // VULNERABILITY 3: Trusts user-provided 'recipient' address
        // Attacker controls where funds ultimately go

        // VULNERABILITY 4: No validation of swap amounts or prices
        // amount0Delta and amount1Delta controlled by attacker
        // Can specify amounts that drain the contract

        // Calculate payment amount based on manipulated parameters
        uint256 amountToPay;
        if (amount0Delta > 0) {
            amountToPay = uint256(amount0Delta);
        } else {
            amountToPay = uint256(amount1Delta);
        }

        // VULNERABILITY 5: Transfers tokens without verifying legitimate swap occurred
        // No check that a real Uniswap swap initiated this callback
        // Attacker gets tokens without providing anything in return

        if (tokenIn == address(WETH)) {
            WETH.withdraw(amountToPay);
            payable(recipient).transfer(amountToPay);
        } else {
            IERC20(tokenIn).transfer(recipient, amountToPay);
        }
    }

    /**
     * @notice Execute settlement (normal flow)
     * @dev This is how the function SHOULD be called, through proper settlement
     */
    function executeSettlement(bytes calldata settlementData) external {
        require(msg.sender == settlement, "Only settlement");
        // Normal settlement logic...
    }

    receive() external payable {}
}

/**
 * EXPLOIT SCENARIO:
 *
 * 1. Attacker identifies vulnerable CowSolver contract:
 *    - Contract: 0xA58cA3013Ed560594557f02420ed77e154De0109
 *    - Has uniswapV3SwapCallback function exposed
 *    - No msg.sender validation on callback
 *
 * 2. Attacker crafts malicious callback data:
 *    - amount0Delta: -1978613680814188858940 (negative, expects to receive)
 *    - amount1Delta: 5373296932158610028 (positive, solver should pay)
 *    - data contains:
 *      * price: 1976408883179648193852
 *      * solver: attacker's address
 *      * tokenIn: WETH address
 *      * recipient: attacker's address
 *
 * 3. Attacker directly calls uniswapV3SwapCallback():
 *    - Calls solver contract's callback function directly
 *    - NOT through a real Uniswap V3 pool swap
 *    - Bypasses all normal swap validation
 *
 * 4. Solver contract processes malicious callback:
 *    - No verification that msg.sender is legitimate Uniswap pool
 *    - Trusts attacker-provided parameters in data
 *    - Calculates payment: amount1Delta = 5.37 WETH
 *
 * 5. Contract sends WETH to attacker:
 *    - Withdraws WETH and converts to ETH
 *    - Sends ETH to attacker-specified recipient
 *    - Attacker receives ~$166K worth of ETH
 *
 * 6. No repayment required:
 *    - Normal Uniswap callback expects tokens in return
 *    - But no validation means attacker pays nothing
 *    - Direct call bypasses pool's token transfer requirements
 *
 * Root Causes:
 * - Missing msg.sender validation in callback function
 * - Callback function marked as external/public instead of internal
 * - No verification that callback came from legitimate Uniswap pool
 * - Trusting user-provided addresses in callback data
 * - No access control on sensitive callback functions
 * - Lack of reentrancy guards
 * - Missing context validation (was a swap actually initiated?)
 *
 * Fix:
 * - Validate msg.sender is a legitimate Uniswap V3 pool:
 *   ```solidity
 *   require(isValidPool[msg.sender], "Unauthorized callback");
 *   ```
 * - Maintain whitelist of approved pool addresses
 * - Use factory.getPool() to verify pool legitimacy
 * - Implement reentrancy guards
 * - Add access control modifiers
 * - Store swap state before initiating, validate in callback
 * - Never trust user-provided addresses in callback data
 * - Make callbacks internal/private when possible
 * - Implement emergency pause functionality
 * - Add maximum transfer limits per callback
 */
