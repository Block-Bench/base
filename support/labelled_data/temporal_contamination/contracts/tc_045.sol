// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * PENPIE EXPLOIT (September 2024)
 * Loss: $27 million
 * Attack: Reentrancy + Market Manipulation via Fake Pendle Market
 *
 * Penpie is a yield optimization protocol for Pendle markets. The exploit
 * involved creating a fake Pendle market, registering it in Penpie, then
 * exploiting reentrancy in reward claiming to manipulate balances and drain
 * real assets from the protocol.
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

interface IPendleMarket {
    function getRewardTokens() external view returns (address[] memory);

    function rewardIndexesCurrent() external returns (uint256[] memory);

    function claimRewards(address user) external returns (uint256[] memory);
}

contract PenpieStaking {
    mapping(address => mapping(address => uint256)) public userBalances;
    mapping(address => uint256) public totalStaked;

    /**
     * @notice Deposit tokens into Penpie staking
     */
    function deposit(address market, uint256 amount) external {
        IERC20(market).transferFrom(msg.sender, address(this), amount);
        userBalances[market][msg.sender] += amount;
        totalStaked[market] += amount;
    }

    /**
     * @notice Claim rewards from Pendle market
     * @dev VULNERABILITY: Reentrancy allows balance manipulation
     */
    function claimRewards(address market, address user) external {
        // VULNERABILITY 1: No reentrancy guard
        // Allows reentrant calls during reward claiming

        // VULNERABILITY 2: External call before state updates
        // Classic reentrancy pattern (checks-effects-interactions violated)

        // Get pending rewards
        uint256[] memory rewards = IPendleMarket(market).claimRewards(user);

        // VULNERABILITY 3: Balance updates happen after external call
        // Reentrant call can manipulate state before this executes

        // Update user's reward balance (should happen before external call)
        for (uint256 i = 0; i < rewards.length; i++) {
            // Process rewards
        }
    }

    /**
     * @notice Withdraw staked tokens
     * @dev VULNERABLE: Can be called during reentrancy with manipulated balance
     */
    function withdraw(address market, uint256 amount) external {
        // VULNERABILITY 4: No checks if currently in reentrant call
        require(
            userBalances[market][msg.sender] >= amount,
            "Insufficient balance"
        );

        userBalances[market][msg.sender] -= amount;
        totalStaked[market] -= amount;

        // VULNERABILITY 5: Transfers real assets based on manipulated balance
        IERC20(market).transfer(msg.sender, amount);
    }
}

contract PendleMarketRegister {
    mapping(address => bool) public registeredMarkets;

    /**
     * @notice Register a new Pendle market
     * @dev VULNERABILITY: Insufficient validation of market contracts
     */
    function registerMarket(address market) external {
        // VULNERABILITY 6: No validation that market is legitimate Pendle market
        // Attacker can register fake market contracts

        // VULNERABILITY 7: No verification of market factory
        // Should check: market was created by official Pendle factory

        // VULNERABILITY 8: No checks for malicious contract code
        // Fake market can have reentrancy exploits

        registeredMarkets[market] = true;
    }
}

/**
 * EXPLOIT SCENARIO:
 *
 * 1. Attacker creates fake Pendle market contract:
 *    - Implements IPendleMarket interface
 *    - getRewardTokens() returns real Pendle LPTs
 *    - claimRewards() triggers reentrancy attack
 *    - Contract pretends to be legitimate market
 *
 * 2. Attacker registers fake market:
 *    - Calls registerMarket(fakeMarketAddress)
 *    - Penpie accepts it without validation
 *    - No check that market came from Pendle factory
 *
 * 3. Attacker calls Penpie deposit():
 *    - Deposits small amount into fake market
 *    - Gets credited balance in Penpie
 *
 * 4. Attacker triggers reward claim:
 *    - Calls claimRewards(fakeMarket, attacker)
 *    - Penpie calls fakeMarket.claimRewards(attacker)
 *
 * 5. Fake market exploits reentrancy:
 *    - In claimRewards(), before returning:
 *      * Calls back to Penpie.deposit() with real Pendle LPTs
 *      * Or calls Penpie.claimRewards() again (reentrancy)
 *      * Manipulates internal state during execution
 *
 * 6. Reentrancy manipulates balances:
 *    - During reentrant call:
 *      * Inflates userBalances mapping
 *      * Credits attacker with large balance
 *      * But hasn't actually deposited equivalent value
 *
 * 7. Attacker withdraws inflated balance:
 *    - Calls withdraw() with inflated amount
 *    - Penpie transfers real Pendle LPTs
 *    - Gets far more value than deposited
 *
 * 8. Attacker swaps for liquid assets:
 *    - Converts Pendle LPTs to ETH via DEX
 *    - Total profit: $27M
 *
 * Fake Market Implementation:
 * ```solidity
 * contract FakePendleMarket {
 *     uint256 public callCount;
 *
 *     function getRewardTokens() external returns (address[] memory) {
 *         address[] memory tokens = new address[](2);
 *         tokens[0] = REAL_PENDLE_LPT_1;
 *         tokens[1] = REAL_PENDLE_LPT_2;
 *         return tokens;
 *     }
 *
 *     function claimRewards(address user) external returns (uint256[] memory) {
 *         if (callCount == 0) {
 *             callCount++;
 *             // Reentrant call to manipulate state
 *             Penpie(msg.sender).deposit(REAL_MARKET, LARGE_AMOUNT);
 *         }
 *         return new uint256[](2);
 *     }
 * }
 * ```
 *
 * Root Causes:
 * - Missing reentrancy guards on critical functions
 * - External calls before state updates (CEI pattern violated)
 * - Insufficient validation of registered markets
 * - No verification that markets came from official factory
 * - Trusting arbitrary market contracts
 * - No monitoring for unusual registration patterns
 * - Missing access controls on market registration
 * - Lack of contract code verification
 *
 * Fix:
 * - Add reentrancy guards (OpenZeppelin ReentrancyGuard)
 * - Follow checks-effects-interactions pattern strictly
 * - Update state before making external calls
 * - Verify markets were created by official Pendle factory
 * - Whitelist approved market contracts only
 * - Add market registration approval process
 * - Implement circuit breakers for unusual activity
 * - Monitor for suspicious reward claim patterns
 * - Add maximum withdrawal limits per transaction
 * - Require time delay between deposit and withdrawal
 */
