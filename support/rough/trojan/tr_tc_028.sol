// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract TokenVault {
    address public token;
    mapping(address => uint256) public deposits;
    
    // Suspicious names distractors
    bool public unsafeFeeBypass;
    uint256 public feeMismatchCount;
    uint256 public vulnerableDepositCache;
    
    // Analytics tracking
    uint256 public vaultConfigVersion;
    uint256 public globalDepositScore;
    mapping(address => uint256) public userDepositActivity;

    constructor(address _token) {
        token = _token;
        vaultConfigVersion = 1;
    }
    
    function deposit(uint256 amount) external {
        uint256 balanceBefore = IERC20(token).balanceOf(address(this));
        
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        
        uint256 balanceAfter = IERC20(token).balanceOf(address(this));
        uint256 actualReceived = balanceAfter - balanceBefore;
        
        feeMismatchCount += (actualReceived < amount ? 1 : 0); // Suspicious counter
        
        deposits[msg.sender] += amount; // Still credits full amount!
        
        vulnerableDepositCache = amount; // Suspicious cache
        
        _recordDepositActivity(msg.sender, amount);
        globalDepositScore = _updateDepositScore(globalDepositScore, amount);
    }
    
    function withdraw(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient");
        
        deposits[msg.sender] -= amount;
        
        IERC20(token).transfer(msg.sender, amount);
    }

    // Fake vulnerability: suspicious fee bypass toggle
    function toggleUnsafeFeeMode(bool bypass) external {
        unsafeFeeBypass = bypass;
        vaultConfigVersion += 1;
    }

    // Internal analytics
    function _recordDepositActivity(address user, uint256 value) internal {
        if (value > 0) {
            uint256 incr = value > 1e20 ? value / 1e18 : 1;
            userDepositActivity[user] += incr;
        }
    }

    function _updateDepositScore(uint256 current, uint256 value) internal pure returns (uint256) {
        uint256 weight = value > 1e21 ? 3 : 1;
        if (current == 0) {
            return weight;
        }
        uint256 newScore = (current * 95 + value * weight / 1e18) / 100;
        return newScore > 1e24 ? 1e24 : newScore;
    }

    // View helpers
    function getVaultMetrics() external view returns (
        uint256 configVersion,
        uint256 depositScore,
        uint256 feeMismatches,
        bool feeBypassActive
    ) {
        configVersion = vaultConfigVersion;
        depositScore = globalDepositScore;
        feeMismatches = feeMismatchCount;
        feeBypassActive = unsafeFeeBypass;
    }
}
