// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Compound cTUSD - Token Sweep Vulnerability
 * @notice This contract demonstrates the vulnerability in Compound's token sweep
 * @dev March 2022 - Allowed sweeping of TUSD due to contract upgrade confusion
 *
 * VULNERABILITY: sweepToken function allowed sweeping upgraded token address
 *
 * ROOT CAUSE:
 * TUSD token was upgraded to a new implementation, but the old implementation
 * address was still registered as the "underlying" token in cTUSD. The sweepToken
 * function was designed to sweep "mistakenly sent" tokens, but it only checked
 * against the old TUSD address, allowing the new TUSD address to be swept.
 *
 * ATTACK VECTOR:
 * 1. TUSD upgraded its token contract to new address
 * 2. cTUSD contract still referenced old TUSD address as "underlying"
 * 3. Attacker noticed this discrepancy
 * 4. Called sweepToken(newTUSDAddress)
 * 5. Function checked: newTUSDAddress != oldTUSDAddress ✓ (passes)
 * 6. Swept all TUSD from cTUSD contract to attacker
 *
 * This is a logic error where the contract failed to account for token upgrades.
 */

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract VulnerableCompoundCToken {
    address public underlying; // Old TUSD address
    address public admin;

    mapping(address => uint256) public accountTokens;
    uint256 public totalSupply;

    // The actual TUSD token was upgraded, but this still points to old address
    address public constant OLD_TUSD =
        0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
    address public constant NEW_TUSD =
        0x0000000000085d4780B73119b644AE5ecd22b376;

    constructor() {
        admin = msg.sender;
        underlying = OLD_TUSD; // Contract references old TUSD address
    }

    /**
     * @notice Supply tokens to the market
     */
    function mint(uint256 amount) external {
        IERC20(NEW_TUSD).transfer(address(this), amount);
        accountTokens[msg.sender] += amount;
        totalSupply += amount;
    }

    /**
     * @notice Sweep accidentally sent tokens
     * @param token Address of token to sweep
     *
     * VULNERABILITY IS HERE:
     * The function only checks if token != underlying (old TUSD address).
     * It doesn't account for the fact that TUSD was upgraded to a new address.
     * So sweepToken(NEW_TUSD) passes the check because NEW_TUSD != OLD_TUSD.
     *
     * Vulnerable logic:
     * 1. Check token != underlying (line 76)
     * 2. underlying = OLD_TUSD address
     * 3. Attacker calls sweepToken(NEW_TUSD)
     * 4. NEW_TUSD != OLD_TUSD, so check passes
     * 5. Transfers all NEW_TUSD tokens to caller
     * 6. But NEW_TUSD is the actual underlying asset!
     */
    function sweepToken(address token) external {
        // VULNERABLE: Only checks against OLD_TUSD address
        // Doesn't account for token upgrades where underlying moved to new address
        require(token != underlying, "Cannot sweep underlying token");

        // This allows sweeping NEW_TUSD because NEW_TUSD != OLD_TUSD
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(msg.sender, balance);
    }

    /**
     * @notice Redeem cTokens for underlying
     */
    function redeem(uint256 amount) external {
        require(accountTokens[msg.sender] >= amount, "Insufficient balance");

        accountTokens[msg.sender] -= amount;
        totalSupply -= amount;

        IERC20(NEW_TUSD).transfer(msg.sender, amount);
    }
}

/**
 * Example attack:
 *
 * 1. Observe that TUSD token upgraded from OLD_TUSD to NEW_TUSD
 * 2. Notice cTUSD contract still references OLD_TUSD as underlying
 * 3. Call cTUSD.sweepToken(NEW_TUSD)
 * 4. Function checks: NEW_TUSD != OLD_TUSD ✓ (passes)
 * 5. All TUSD swept from cTUSD to attacker
 * 6. Legitimate users can't redeem their cTUSD anymore
 *
 * REAL-WORLD IMPACT:
 * - Affected Compound cTUSD market
 * - Allowed sweeping of actual underlying asset
 * - No funds lost because exploiter returned them
 * - Highlighted risks of token upgrades in DeFi
 *
 * FIX:
 * Track all valid underlying token addresses, including upgraded versions:
 *
 * mapping(address => bool) public isUnderlying;
 *
 * constructor() {
 *     admin = msg.sender;
 *     isUnderlying[OLD_TUSD] = true;
 *     isUnderlying[NEW_TUSD] = true;  // Add new address
 * }
 *
 * function sweepToken(address token) external {
 *     require(!isUnderlying[token], "Cannot sweep underlying token");
 *     uint256 balance = IERC20(token).balanceOf(address(this));
 *     IERC20(token).transfer(msg.sender, balance);
 * }
 *
 * Or check both old and new addresses:
 *
 * function sweepToken(address token) external {
 *     require(
 *         token != OLD_TUSD && token != NEW_TUSD,
 *         "Cannot sweep underlying"
 *     );
 *     uint256 balance = IERC20(token).balanceOf(address(this));
 *     IERC20(token).transfer(msg.sender, balance);
 * }
 *
 * VULNERABLE LINES:
 * - Line 45: underlying points to OLD_TUSD
 * - Line 76: Only checks token != underlying (OLD_TUSD)
 * - Line 80: Sweeps any token except OLD_TUSD, including NEW_TUSD
 *
 * KEY LESSON:
 * When tokens upgrade to new addresses, all dependent contracts must be updated.
 * sweepToken and similar "rescue" functions must account for all valid underlying
 * token addresses, including legacy and upgraded versions.
 * Token upgrades create subtle vulnerabilities in integration contracts.
 */
