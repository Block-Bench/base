// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title PancakeHunny - Balance Calculation Vulnerability
 * @notice This contract demonstrates the vulnerability that led to the PancakeHunny hack
 * @dev May 20, 2021 - $45M stolen through incorrect balance calculation
 *
 * VULNERABILITY: Using balanceOf for fee calculation allowing flash loan manipulation
 *
 * ROOT CAUSE:
 * The mintFor() function calculates reward tokens based on contract's current token balance
 * using balanceOf(address(this)). An attacker can artificially inflate this balance
 * by sending tokens directly to the contract before calling the function, then
 * immediately withdrawing after, tricking the contract into minting excessive rewards.
 *
 * ATTACK VECTOR:
 * 1. Attacker deposits large amount of LP tokens to vault
 * 2. Attacker transfers additional LP tokens directly to the minter contract
 * 3. Attacker calls getReward() which triggers mintFor()
 * 4. mintFor() sees inflated balance from step 2, mints excessive HUNNY rewards
 * 5. Attacker receives far more HUNNY tokens than earned
 * 6. Attacker sells HUNNY tokens for profit
 *
 * This vulnerability often combines with flash loans to amplify the attack.
 */

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface IPancakeRouter {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract VulnerableHunnyMinter {
    IERC20 public lpToken;      // LP token (e.g., CAKE-BNB)
    IERC20 public rewardToken;  // HUNNY reward token
    
    mapping(address => uint256) public depositedLP;
    mapping(address => uint256) public earnedRewards;
    
    uint256 public constant REWARD_RATE = 100; // 100 reward tokens per LP token

    constructor(address _lpToken, address _rewardToken) {
        lpToken = IERC20(_lpToken);
        rewardToken = IERC20(_rewardToken);
    }

    /**
     * @notice Deposit LP tokens to earn rewards
     */
    function deposit(uint256 amount) external {
        lpToken.transferFrom(msg.sender, address(this), amount);
        depositedLP[msg.sender] += amount;
    }

    /**
     * @notice Calculate and mint rewards for user
     * @param flip The LP token address
     * @param _withdrawalFee Withdrawal fee amount
     * @param _performanceFee Performance fee amount
     * @param to Recipient address
     *
     * VULNERABILITY IS HERE:
     * The function uses balanceOf(address(this)) to calculate rewards.
     * This includes ALL tokens in the contract, not just legitimate deposits.
     *
     * Vulnerable sequence:
     * 1. User has legitimately deposited some LP tokens
     * 2. User transfers EXTRA LP tokens directly to contract (line 88)
     * 3. mintFor() is called (line 90)
     * 4. Line 95 uses balanceOf which includes the extra tokens
     * 5. tokenToReward() calculates rewards based on inflated balance
     * 6. User receives excessive rewards
     * 7. Extra LP tokens can be withdrawn later
     */
    function mintFor(
        address flip,
        uint256 _withdrawalFee,
        uint256 _performanceFee,
        address to,
        uint256 /* amount - unused */
    ) external {
        require(flip == address(lpToken), "Invalid token");
        
        // Transfer fees from caller
        uint256 feeSum = _performanceFee + _withdrawalFee;
        lpToken.transferFrom(msg.sender, address(this), feeSum);
        
        // VULNERABLE: Use balanceOf to calculate rewards
        // This includes tokens sent directly to contract, not just fees
        uint256 hunnyRewardAmount = tokenToReward(lpToken.balanceOf(address(this)));
        
        // Mint excessive rewards
        earnedRewards[to] += hunnyRewardAmount;
    }

    /**
     * @notice Convert LP token amount to reward amount
     * @dev This is called with the inflated balance
     */
    function tokenToReward(uint256 lpAmount) internal pure returns (uint256) {
        return lpAmount * REWARD_RATE;
    }

    /**
     * @notice Claim earned rewards
     */
    function getReward() external {
        uint256 reward = earnedRewards[msg.sender];
        require(reward > 0, "No rewards");
        
        earnedRewards[msg.sender] = 0;
        rewardToken.transfer(msg.sender, reward);
    }

    /**
     * @notice Withdraw deposited LP tokens
     */
    function withdraw(uint256 amount) external {
        require(depositedLP[msg.sender] >= amount, "Insufficient balance");
        depositedLP[msg.sender] -= amount;
        lpToken.transfer(msg.sender, amount);
    }
}

/**
 * Example attack flow:
 *
 * 1. Attacker obtains large amount of LP tokens (via flash loan)
 * 2. Attacker deposits small amount to vault: deposit(1 ether)
 * 3. Attacker transfers large amount directly to minter: lpToken.transfer(minter, 100 ether)
 * 4. Vault calls mintFor() on behalf of attacker
 * 5. mintFor() calculates: tokenToReward(101 ether) = 10,100 HUNNY
 * 6. Attacker should only get tokenToReward(1 ether) = 100 HUNNY
 * 7. Attacker received 101x more rewards than deserved
 * 8. Attacker swaps HUNNY for profit, repays flash loan
 *
 * REAL-WORLD IMPACT:
 * - $45M stolen in May 2021
 * - HUNNY token price crashed 99%
 * - Multiple vaults affected
 * - Attacker used flash loans to amplify the attack
 *
 * FIX:
 * Never use balanceOf for reward calculations. Track deposits explicitly:
 *
 * mapping(address => uint256) public totalDeposited;
 *
 * function mintFor(...) external {
 *     uint256 feeSum = _performanceFee + _withdrawalFee;
 *     lpToken.transferFrom(msg.sender, address(this), feeSum);
 *     
 *     // Use tracked amount, not balanceOf
 *     totalDeposited += feeSum;
 *     uint256 hunnyRewardAmount = tokenToReward(feeSum);  // Only use actual fees
 *     
 *     earnedRewards[to] += hunnyRewardAmount;
 * }
 *
 * Alternative: Store balance before transfer, calculate delta:
 *
 * uint256 balanceBefore = lpToken.balanceOf(address(this));
 * lpToken.transferFrom(msg.sender, address(this), feeSum);
 * uint256 actualReceived = lpToken.balanceOf(address(this)) - balanceBefore;
 * uint256 hunnyRewardAmount = tokenToReward(actualReceived);
 *
 * VULNERABLE LINES:
 * - Line 95: balanceOf includes all tokens, not just legitimate deposits/fees
 * - Line 98: Rewards calculated on inflated balance
 *
 * KEY LESSON:
 * Never use balanceOf(address(this)) for business logic.
 * Anyone can inflate contract's balance by sending tokens directly.
 * Always track deposits/transfers explicitly or calculate delta.
 * Be especially careful with flash loan-amplified attacks.
 */
