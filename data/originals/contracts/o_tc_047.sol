// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * PLAYDAPP EXPLOIT (February 2024)
 * Loss: $290 million (in token value)
 * Attack: Unauthorized Token Minting via Compromised Private Key
 *
 * VULNERABILITY OVERVIEW:
 * PlayDapp's PLA token was exploited when attackers gained access to a private key
 * with minting privileges. They minted 1.79 billion PLA tokens (~$290M at the time),
 * which were immediately sold on DEXes, causing massive token price collapse.
 *
 * ROOT CAUSE:
 * 1. Single private key controlled minting function
 * 2. No multi-signature requirement for minting
 * 3. Missing minting cap or supply limit
 * 4. No timelock delay for mint operations
 * 5. Insufficient monitoring of large mints
 *
 * ATTACK FLOW:
 * 1. Attacker compromised private key with MINTER_ROLE
 * 2. Called mint() repeatedly to create 1.79B tokens
 * 3. Sold tokens on multiple DEXes (Uniswap, etc.)
 * 4. Token price collapsed ~90% due to supply shock
 * 5. PlayDapp attempted migration to new token contract
 * 6. Attacker repeated the exploit on new contract as well
 */

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

/**
 * Simplified model of PlayDapp's vulnerable token contract
 */
contract PlayDappToken {
    string public name = "PlayDapp Token";
    string public symbol = "PLA";
    uint8 public decimals = 18;

    uint256 public totalSupply;

    // VULNERABILITY 1: Single minter address with unlimited power
    address public minter;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Minted(address indexed to, uint256 amount);

    constructor() {
        minter = msg.sender;
        // Initial supply minted
        _mint(msg.sender, 700_000_000 * 10 ** 18); // 700M initial supply
    }

    /**
     * @dev VULNERABILITY 2: Minting controlled by single private key
     * @dev VULNERABILITY 3: No multi-sig requirement
     */
    modifier onlyMinter() {
        require(msg.sender == minter, "Not minter");
        _;
    }

    /**
     * @dev CRITICAL VULNERABILITY: Unrestricted minting function
     * @dev VULNERABILITY 4: No supply cap enforcement
     * @dev VULNERABILITY 5: No rate limiting or minting cooldown
     * @dev VULNERABILITY 6: No timelock delay
     */
    function mint(address to, uint256 amount) external onlyMinter {
        // VULNERABILITY 7: No validation of mint amount
        // Attacker can mint unlimited tokens in single transaction

        // VULNERABILITY 8: No circuit breaker for unusual minting activity
        // VULNERABILITY 9: No multi-step confirmation required

        _mint(to, amount);
        emit Minted(to, amount);
    }

    /**
     * @dev Internal mint function with no safeguards
     */
    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "Mint to zero address");

        // VULNERABILITY 10: totalSupply can grow without bound
        totalSupply += amount;
        balanceOf[to] += amount;

        emit Transfer(address(0), to, amount);
    }

    /**
     * @dev Change minter - equally vulnerable
     */
    function setMinter(address newMinter) external onlyMinter {
        // VULNERABILITY 11: Minter can be changed without timelock
        // VULNERABILITY 12: No confirmation from new minter required
        minter = newMinter;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(
            allowance[from][msg.sender] >= amount,
            "Insufficient allowance"
        );

        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;

        emit Transfer(from, to, amount);
        return true;
    }
}

/**
 * ATTACK SCENARIO:
 *
 * Phase 1 - First Exploit (February 9, 2024):
 * 1. Attacker compromises minter private key
 * 2. Calls mint(attackerWallet, 1_790_000_000 * 10**18)
 * 3. Receives 1.79 billion PLA tokens (~$290M at time)
 * 4. Sells tokens across multiple DEXes:
 *    - Uniswap: ~$50M
 *    - PancakeSwap: ~$100M
 *    - Other DEXes: ~$140M
 * 5. Token price crashes from ~$0.16 to ~$0.016 (90% drop)
 *
 * Phase 2 - PlayDapp Response:
 * 1. PlayDapp pauses original contract
 * 2. Announces token migration to new contract
 * 3. Deploys new PLA token with "improved security"
 *
 * Phase 3 - Second Exploit (February 13, 2024):
 * 1. Attacker gains access to NEW token's minter key
 * 2. Mints additional 1.59 billion tokens on new contract
 * 3. Further market damage and user confidence loss
 *
 * MITIGATION STRATEGIES:
 *
 * 1. Supply Cap:
 *    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10**18;
 *    require(totalSupply + amount <= MAX_SUPPLY, "Exceeds cap");
 *
 * 2. Multi-Signature Minting:
 *    - Require 3-of-5 signatures for minting
 *    - Distribute keys across team and security providers
 *
 * 3. Timelock Delay:
 *    - Add 24-48 hour delay for minting operations
 *    - Allows community to detect malicious minting
 *
 * 4. Rate Limiting:
 *    mapping(uint256 => uint256) public dailyMinted;
 *    uint256 public constant DAILY_MINT_LIMIT = 1_000_000 * 10**18;
 *    require(dailyMinted[block.timestamp / 1 days] + amount <= DAILY_MINT_LIMIT);
 *
 * 5. Minting Schedule:
 *    - Predefined vesting schedule
 *    - No ad-hoc minting allowed
 *
 * 6. Role-Based Access Control:
 *    - Use OpenZeppelin AccessControl
 *    - Separate roles for different operations
 *    - Multiple addresses required for critical functions
 *
 * 7. Circuit Breakers:
 *    - Automatic pause if unusual minting detected
 *    - Require manual review for large mints
 *
 * 8. Hardware Security:
 *    - Store minter keys in HSM
 *    - Require physical presence for minting
 *
 * 9. Monitoring:
 *    - Real-time alerts for any minting activity
 *    - Dashboard showing supply changes
 *    - Automatic notifications to team
 *
 * 10. Immutable Supply:
 *     - Consider non-mintable token design
 *     - All supply created at deployment
 *     - Eliminates minting vulnerabilities entirely
 */
