// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * FIXEDFLOAT EXPLOIT (February 2024)
 * Loss: $26 million
 * Attack: Private Key Compromise + Unauthorized Withdrawals
 *
 * VULNERABILITY OVERVIEW:
 * FixedFloat, a crypto exchange platform, suffered a massive exploit when attackers
 * compromised private keys controlling the platform's hot wallets. The compromised keys
 * allowed direct withdrawal of funds without any authorization checks or multi-sig protection.
 *
 * ROOT CAUSE:
 * 1. Single private key controlled withdrawal functions
 * 2. No multi-signature requirement for large withdrawals
 * 3. Missing timelock for critical operations
 * 4. Insufficient monitoring and alerting
 * 5. No withdrawal limits or rate limiting
 *
 * ATTACK FLOW:
 * 1. Attackers compromised admin private keys (phishing/malware suspected)
 * 2. Used compromised keys to call withdraw() directly
 * 3. Drained Bitcoin and Ethereum from hot wallets
 * 4. No timelock delayed the malicious withdrawals
 * 5. Transferred stolen funds through mixers
 * 6. Total loss: ~$26M in BTC and ETH
 */

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

/**
 * Simplified model of FixedFloat's vulnerable withdrawal system
 */
contract FixedFloatHotWallet {
    address public owner;

    // VULNERABILITY 1: Single owner controls all funds
    // No multi-sig, no timelock, no withdrawal limits

    mapping(address => bool) public authorizedOperators;

    event Withdrawal(address token, address to, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev VULNERABILITY 2: Single private key compromise = total loss
     * @dev VULNERABILITY 3: No multi-signature requirement
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /**
     * @dev VULNERABILITY 4: No timelock delay for withdrawals
     * @dev VULNERABILITY 5: No maximum withdrawal limits
     * @dev VULNERABILITY 6: Can drain entire balance in single transaction
     */
    function withdraw(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {
        // VULNERABILITY 7: No additional authorization checks
        // VULNERABILITY 8: No rate limiting
        // VULNERABILITY 9: No monitoring or pause mechanism

        if (token == address(0)) {
            // Withdraw ETH
            payable(to).transfer(amount);
        } else {
            // Withdraw ERC20 tokens
            IERC20(token).transfer(to, amount);
        }

        emit Withdrawal(token, to, amount);
    }

    /**
     * @dev Emergency withdrawal - same vulnerability as regular withdraw
     */
    function emergencyWithdraw(address token) external onlyOwner {
        // VULNERABILITY 10: Emergency function has same weak access control

        uint256 balance;
        if (token == address(0)) {
            balance = address(this).balance;
            payable(owner).transfer(balance);
        } else {
            balance = IERC20(token).balanceOf(address(this));
            IERC20(token).transfer(owner, balance);
        }

        emit Withdrawal(token, owner, balance);
    }

    /**
     * @dev Transfer ownership - critical function with no protection
     */
    function transferOwnership(address newOwner) external onlyOwner {
        // VULNERABILITY 11: Ownership transfer has no timelock
        // VULNERABILITY 12: No confirmation from new owner required
        owner = newOwner;
    }

    receive() external payable {}
}

/**
 * ATTACK SCENARIO:
 *
 * 1. Attacker compromises owner private key through:
 *    - Phishing attack targeting FixedFloat admin
 *    - Malware on admin's computer
 *    - Social engineering
 *
 * 2. With compromised key, attacker calls:
 *    hotWallet.withdraw(WBTC_ADDRESS, attackerAddress, balance)
 *    hotWallet.withdraw(address(0), attackerAddress, ethBalance)
 *
 * 3. Funds transferred immediately with no delays:
 *    - ~$15M in Bitcoin
 *    - ~$11M in Ethereum
 *
 * 4. Attacker routes funds through mixers to obfuscate trail
 *
 * 5. No recovery possible due to irreversibility of blockchain transactions
 *
 * MITIGATION STRATEGIES:
 *
 * 1. Multi-Signature Wallet:
 *    - Require 3-of-5 or 4-of-7 signatures for withdrawals
 *    - Distribute keys across different individuals/locations
 *
 * 2. Timelock Mechanism:
 *    - Add 24-48 hour delay for large withdrawals
 *    - Allow time for detection and intervention
 *
 * 3. Withdrawal Limits:
 *    - Implement daily/hourly withdrawal caps
 *    - Require additional approvals for amounts exceeding limits
 *
 * 4. Hardware Security Modules (HSM):
 *    - Store private keys in dedicated hardware
 *    - Prevent key extraction even if system compromised
 *
 * 5. Monitoring and Alerts:
 *    - Real-time monitoring of large withdrawals
 *    - Automatic alerts to multiple team members
 *    - Pause mechanism for suspicious activity
 *
 * 6. Cold Storage:
 *    - Keep majority of funds in cold wallets
 *    - Hot wallets hold only operational amounts
 *
 * 7. Key Rotation:
 *    - Regular rotation of private keys
 *    - Limit exposure window if key compromised
 *
 * 8. Access Control:
 *    - Role-based permissions
 *    - Separation of duties
 *    - No single person has complete control
 */
