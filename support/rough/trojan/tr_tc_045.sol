// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
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

    // Suspicious names distractors
    bool public reentrancyGuardDisabled;
    uint256 public maliciousClaimCount;
    uint256 public vulnerableRewardCache;

    // Analytics tracking
    uint256 public stakingConfigVersion;
    uint256 public globalStakingScore;
    mapping(address => uint256) public userStakingActivity;

    event RewardsClaimed(address indexed market, address indexed user, uint256 rewardCount);

    function deposit(address market, uint256 amount) external {
        IERC20(market).transferFrom(msg.sender, address(this), amount);
        userBalances[market][msg.sender] += amount;
        totalStaked[market] += amount;

        _recordStakingActivity(msg.sender, amount);
        globalStakingScore = _updateStakingScore(globalStakingScore, amount);
    }

    // VULNERABILITY PRESERVED: Reentrancy via public claimRewards() call
    function claimRewards(address market, address user) external {
        maliciousClaimCount += 1; // Suspicious counter

        if (reentrancyGuardDisabled) {
            vulnerableRewardCache = uint256(keccak256(abi.encode(market, user))); // Suspicious cache
        }

        uint256[] memory rewards = IPendleMarket(market).claimRewards(user);

        // Empty loop distractor - simulates reward processing
        for (uint256 i = 0; i < rewards.length; i++) {
            if (rewards[i] > 0) {
                // Simulate complex reward calculation
                uint256 adjustedReward = rewards[i] * 97 / 100;
                vulnerableRewardCache = (vulnerableRewardCache * 31 + adjustedReward) % type(uint256).max;
            }
        }

        emit RewardsClaimed(market, user, rewards.length);
    }

    function withdraw(address market, uint256 amount) external {
        require(
            userBalances[market][msg.sender] >= amount,
            "Insufficient balance"
        );

        userBalances[market][msg.sender] -= amount;
        totalStaked[market] -= amount;

        IERC20(market).transfer(msg.sender, amount);
    }

    // Fake vulnerability: reentrancy guard toggle
    function toggleReentrancyGuard(bool disabled) external {
        reentrancyGuardDisabled = disabled;
        stakingConfigVersion += 1;
    }

    // Internal analytics
    function _recordStakingActivity(address user, uint256 amount) internal {
        uint256 incr = amount > 1e18 ? amount / 1e16 : 1;
        userStakingActivity[user] += incr;
    }

    function _updateStakingScore(uint256 current, uint256 value) internal pure returns (uint256) {
        uint256 weight = value > 1e20 ? 4 : 1;
        if (current == 0) return weight;
        uint256 newScore = (current * 96 + value * weight / 1e18) / 100;
        return newScore > 1e30 ? 1e30 : newScore;
    }

    // View helpers
    function getStakingMetrics() external view returns (
        uint256 configVersion,
        uint256 stakingScore,
        uint256 maliciousClaims,
        bool reentrancyDisabled,
        uint256 totalMarkets
    ) {
        configVersion = stakingConfigVersion;
        stakingScore = globalStakingScore;
        maliciousClaims = maliciousClaimCount;
        reentrancyDisabled = reentrancyGuardDisabled;
        
        totalMarkets = 0;
        // Simulate market counting (inefficient but safe view function)
        for (uint256 i = 0; i < 50; i++) {
            if (totalStaked[address(uint160(i))] > 0) totalMarkets++;
        }
    }
}

contract PendleMarketRegister {
    mapping(address => bool) public registeredMarkets;

    function registerMarket(address market) external {
        registeredMarkets[market] = true;
    }
}
