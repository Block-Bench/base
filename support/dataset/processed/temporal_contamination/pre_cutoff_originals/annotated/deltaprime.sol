// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * DELTAPRIME EXPLOIT (November 2024)
 * Loss: $4.75 million (note: second incident, total ~$6M)
 * Attack: Private Key Compromise + Malicious Contract Injection
 *
 * DeltaPrime is a cross-margin lending protocol. Attackers compromised a
 * privileged private key that could upgrade proxy contracts. They upgraded
 * a pool contract to inject malicious code, then manipulated reward claiming
 * to drain funds through fake pair contracts.
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

interface ISmartLoan {
    function swapDebtParaSwap(
        bytes32 _fromAsset,
        bytes32 _toAsset,
        uint256 _repayAmount,
        uint256 _borrowAmount,
        bytes4 selector,
        bytes memory data
    ) external;

    function claimReward(address pair, uint256[] calldata ids) external;
}

contract SmartLoansFactory {
    address public admin;

    constructor() {
        admin = msg.sender;
    }

    function createLoan() external returns (address) {
        SmartLoan loan = new SmartLoan();
        return address(loan);
    }

    /**
     * @notice Upgrade a pool contract
     * @dev VULNERABILITY: Private key for this function was compromised
     */
    function upgradePool(
        address poolProxy,
        address newImplementation
    ) external {
        // VULNERABILITY 1: Single private key controls upgrades
        // No multi-sig requirement
        // No timelock delay
        require(msg.sender == admin, "Not admin");

        // VULNERABILITY 2: Can upgrade to arbitrary malicious implementation
        // No validation of new implementation code
        // Attacker uploaded malicious implementation

        // Upgrade the proxy to point to new implementation
        // (Simplified - actual upgrade uses proxy pattern)
    }
}

contract SmartLoan is ISmartLoan {
    mapping(bytes32 => uint256) public deposits;
    mapping(bytes32 => uint256) public debts;

    /**
     * @notice Swap debt between assets via ParaSwap
     * @dev VULNERABLE: Can be exploited after malicious upgrade
     */
    function swapDebtParaSwap(
        bytes32 _fromAsset,
        bytes32 _toAsset,
        uint256 _repayAmount,
        uint256 _borrowAmount,
        bytes4 selector,
        bytes memory data
    ) external override {
        // VULNERABILITY 3: After malicious upgrade, this function can be manipulated
        // Attacker's upgraded version allows arbitrary external calls
        // Simplified swap logic
        // In exploit: made calls to malicious contracts
    }

    /**
     * @notice Claim rewards from staking pairs
     * @dev VULNERABILITY 4: Accepts user-controlled pair address
     */
    function claimReward(
        address pair,
        uint256[] calldata ids
    ) external override {
        // VULNERABILITY 5: No validation of pair contract address
        // Attacker can provide malicious fake pair contract

        // VULNERABILITY 6: Arbitrary external call to user-provided address
        // Call to pair contract to claim rewards
        (bool success, ) = pair.call(
            abi.encodeWithSignature("claimRewards(address)", msg.sender)
        );

        // Malicious pair contract can manipulate balances and drain funds
    }
}

/**
 * EXPLOIT SCENARIO:
 *
 * 1. Attacker compromises admin private key:
 *    - Through phishing, malware, or other means
 *    - Gains control of upgrade functionality
 *    - Can now upgrade any pool contract
 *
 * 2. Attacker prepares malicious implementation:
 *    - Creates contract with backdoor functions
 *    - Includes functions to manipulate balances
 *    - Allows calling arbitrary external addresses
 *
 * 3. Attacker upgrades pool contract:
 *    - Uses compromised key to call upgradePool()
 *    - Points proxy to malicious implementation
 *    - No timelock delay allows immediate execution
 *
 * 4. Attacker creates smart loan position:
 *    - Calls createLoan() to get loan contract
 *    - Contract now uses malicious upgraded code
 *
 * 5. Attacker obtains massive flashloan:
 *    - Borrows all available WETH from Balancer
 *    - Amount: Protocol's entire liquidity
 *
 * 6. Attacker wraps ETH and manipulates position:
 *    - Deposits flashloaned WETH
 *    - Uses malicious swapDebtParaSwap() to manipulate balances
 *
 * 7. Attacker calls claimReward with fake pair:
 *    - Creates malicious pair contract
 *    - Pair contract's claimRewards() manipulates loan state
 *    - Inflates attacker's balance artificially
 *
 * 8. Attacker withdraws inflated balance:
 *    - Extracts $4.75M in real WETH
 *    - Repays flashloan
 *    - Keeps profit
 *
 * Root Causes:
 * - Private key compromise (single point of failure)
 * - No multi-sig requirement for upgrades
 * - Missing timelock on upgrade function
 * - Lack of upgrade safeguards and validation
 * - No monitoring of upgrade transactions
 * - User-controlled addresses in claimReward()
 * - Arbitrary external calls without validation
 * - Insufficient access control on sensitive functions
 *
 * Fix:
 * - Implement multi-sig for all admin functions
 * - Add timelock delay (24-48 hours) for upgrades
 * - Use hardware security modules (HSMs) for keys
 * - Implement upgrade validation and review process
 * - Whitelist allowed pair contract addresses
 * - Add circuit breakers for unusual transactions
 * - Monitor for upgrade transactions and pause if detected
 * - Implement two-step upgrade with verification period
 * - Use decentralized governance for upgrades
 * - Regular security audits and key rotation
 */
