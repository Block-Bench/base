// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * MUNCHABLES EXPLOIT (March 2024)
 * Loss: $62 million (fully recovered)
 * Attack: Developer Private Key Compromise + Malicious Contract Upgrade
 *
 * VULNERABILITY OVERVIEW:
 * Munchables, a GameFi project on Blast L2, suffered an exploit when a rogue developer
 * with access to privileged private keys upgraded contracts to malicious implementations.
 * The attacker locked user funds by setting withdrawal addresses to their own control.
 *
 * UNIQUE ASPECT: Funds were fully recovered after negotiations with the attacker,
 * who turned out to be a North Korean developer hired by the project.
 *
 * ROOT CAUSE:
 * 1. Single developer had access to critical private keys
 * 2. No multi-signature requirement for contract upgrades
 * 3. Missing timelock delay for critical operations
 * 4. Insufficient background checks on developers with key access
 * 5. No code review process for upgrades
 *
 * ATTACK FLOW:
 * 1. Rogue developer prepared malicious contract implementation
 * 2. Used admin keys to upgrade LockManager contract
 * 3. Malicious contract allowed setting arbitrary lock recipients
 * 4. Transferred all user funds to attacker-controlled addresses
 * 5. $62M in ETH/WETH locked in attacker wallets
 * 6. Project negotiated with attacker (revealed to be DPRK dev)
 * 7. Full funds returned and project resumed operations
 */

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

/**
 * Munchables Lock Manager (Vulnerable Version)
 */
contract MunchablesLockManager {
    address public admin;
    address public configStorage;

    struct PlayerSettings {
        uint256 lockedAmount;
        address lockRecipient;
        uint256 lockDuration;
        uint256 lockStartTime;
    }

    // VULNERABILITY 1: Admin has unrestricted control
    mapping(address => PlayerSettings) public playerSettings;
    mapping(address => uint256) public playerBalances;

    IERC20 public immutable weth;

    event Locked(address player, uint256 amount, address recipient);
    event ConfigUpdated(address oldConfig, address newConfig);

    constructor(address _weth) {
        admin = msg.sender;
        weth = IERC20(_weth);
    }

    /**
     * @dev VULNERABILITY 2: Single admin modifier, no multi-sig
     */
    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    /**
     * @dev Users lock tokens to earn rewards
     */
    function lock(uint256 amount, uint256 duration) external {
        require(amount > 0, "Zero amount");

        weth.transferFrom(msg.sender, address(this), amount);

        playerBalances[msg.sender] += amount;
        playerSettings[msg.sender] = PlayerSettings({
            lockedAmount: amount,
            lockRecipient: msg.sender,
            lockDuration: duration,
            lockStartTime: block.timestamp
        });

        emit Locked(msg.sender, amount, msg.sender);
    }

    /**
     * @dev VULNERABILITY 3: Admin can change configStorage without restrictions
     * @dev VULNERABILITY 4: No timelock delay for critical changes
     */
    function setConfigStorage(address _configStorage) external onlyAdmin {
        // VULNERABILITY 5: Immediate execution, no delay
        address oldConfig = configStorage;
        configStorage = _configStorage;

        emit ConfigUpdated(oldConfig, _configStorage);
    }

    /**
     * @dev VULNERABILITY 6: Admin can modify user settings arbitrarily
     * @dev This is the key function exploited by rogue developer
     */
    function setLockRecipient(
        address player,
        address newRecipient
    ) external onlyAdmin {
        // VULNERABILITY 7: No validation of newRecipient
        // VULNERABILITY 8: Can redirect all user funds to attacker
        // VULNERABILITY 9: No user consent required

        playerSettings[player].lockRecipient = newRecipient;
    }

    /**
     * @dev Unlock funds after lock period expires
     */
    function unlock() external {
        PlayerSettings memory settings = playerSettings[msg.sender];

        require(settings.lockedAmount > 0, "No locked tokens");
        require(
            block.timestamp >= settings.lockStartTime + settings.lockDuration,
            "Still locked"
        );

        uint256 amount = settings.lockedAmount;

        // VULNERABILITY 10: Funds sent to potentially attacker-controlled recipient
        address recipient = settings.lockRecipient;

        delete playerSettings[msg.sender];
        playerBalances[msg.sender] = 0;

        weth.transfer(recipient, amount);
    }

    /**
     * @dev VULNERABILITY 11: Emergency withdrawal also uses lockRecipient
     */
    function emergencyUnlock(address player) external onlyAdmin {
        PlayerSettings memory settings = playerSettings[player];
        uint256 amount = settings.lockedAmount;
        address recipient = settings.lockRecipient;

        delete playerSettings[player];
        playerBalances[player] = 0;

        // Sends to whoever admin set as lockRecipient
        weth.transfer(recipient, amount);
    }

    /**
     * @dev VULNERABILITY 12: Admin transfer with no restrictions
     */
    function transferAdmin(address newAdmin) external onlyAdmin {
        // VULNERABILITY 13: No timelock, no multi-sig confirmation
        admin = newAdmin;
    }
}

/**
 * ATTACK SCENARIO:
 *
 * Preparation Phase:
 * 1. Rogue developer (later revealed as North Korean operative) gains employment
 * 2. Developer given access to admin private keys for "development purposes"
 * 3. Project has ~$62M in user deposits locked in contracts
 *
 * Exploitation Phase (March 26, 2024):
 *
 * Step 1: Upgrade to Malicious Implementation
 * - Developer uses admin key to upgrade LockManager to malicious version
 * - Malicious version allows arbitrary setLockRecipient calls
 *
 * Step 2: Redirect All User Funds
 * - For each user with locked funds:
 *   setLockRecipient(user, attackerWallet)
 *
 * Step 3: Trigger Emergency Unlocks
 * - Call emergencyUnlock() for all users
 * - Funds flow to attacker's lockRecipient addresses
 * - Total drained: $62M in ETH/WETH
 *
 * Step 4: Transfer to External Wallets
 * - Attacker moves funds across multiple wallets
 * - Prepares for mixing/laundering
 *
 * Recovery Phase (Unusual Outcome):
 *
 * 1. Munchables team traces attacker identity
 * 2. Discovers attacker is DPRK-linked developer
 * 3. Opens negotiations through intermediaries
 * 4. Attacker agrees to return all funds (reasons unclear)
 * 5. All $62M returned to project
 * 6. Project compensates affected users
 * 7. Upgrades security and continues operations
 *
 * MITIGATION STRATEGIES:
 *
 * 1. Multi-Signature Requirements:
 *    // Require 3-of-5 signatures for admin actions
 *    modifier onlyMultiSig() {
 *        require(multiSig.isConfirmed(msg.data), "Not confirmed");
 *        _;
 *    }
 *
 * 2. Timelock Delays:
 *    uint256 public constant ADMIN_DELAY = 48 hours;
 *    mapping(bytes32 => uint256) public scheduledActions;
 *
 *    function scheduleSetRecipient(...) external onlyAdmin {
 *        bytes32 actionHash = keccak256(abi.encode(...));
 *        scheduledActions[actionHash] = block.timestamp + ADMIN_DELAY;
 *    }
 *
 * 3. User Consent Required:
 *    function setLockRecipient(address newRecipient) external {
 *        // Only users can change their own recipient
 *        require(msg.sender == player, "Only user");
 *        playerSettings[msg.sender].lockRecipient = newRecipient;
 *    }
 *
 * 4. Immutable Critical Functions:
 *    // Remove admin override capabilities
 *    // Users have full control of their funds
 *
 * 5. Developer Vetting:
 *    - Thorough background checks
 *    - Principle of least privilege
 *    - No single person has critical key access
 *
 * 6. Code Review Process:
 *    - All upgrades reviewed by multiple team members
 *    - External audit before deployment
 *    - Community governance for changes
 *
 * 7. Hardware Security:
 *    - Admin keys stored in HSMs
 *    - Physical presence required
 *    - Geographic distribution
 *
 * 8. Monitoring and Alerts:
 *    - Real-time alerts on admin actions
 *    - Automatic pause on suspicious activity
 *    - Community oversight dashboard
 *
 * 9. Gradual Privilege Escalation:
 *    - New developers start with limited access
 *    - Increase privileges over time with trust
 *    - Regular security training
 *
 * 10. Decentralized Governance:
 *     - Move to DAO-controlled upgrades
 *     - Token holder voting
 *     - Eliminate single points of failure
 */
