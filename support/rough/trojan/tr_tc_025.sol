// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface ICompoundToken {
    function borrow(uint256 amount) external;
    function repayBorrow(uint256 amount) external;
    function redeem(uint256 tokens) external;
    function mint(uint256 amount) external;
}

contract LendingMarket {
    mapping(address => uint256) public accountBorrows;
    mapping(address => uint256) public accountTokens;
    
    address public underlying;
    uint256 public totalBorrows;

    // Suspicious names distractors
    bool public unsafeBorrowBypass;
    uint256 public reentrantBorrowCount;
    uint256 public vulnerableDebtCache;

    // Analytics tracking
    uint256 public marketConfigVersion;
    uint256 public globalBorrowScore;
    mapping(address => uint256) public userBorrowActivity;

    constructor(address _underlying) {
        underlying = _underlying;
        marketConfigVersion = 1;
    }
    
    function borrow(uint256 amount) external {
        reentrantBorrowCount += 1; // Suspicious counter

        accountBorrows[msg.sender] += amount;
        totalBorrows += amount;
        
        vulnerableDebtCache = amount; // Suspicious cache
        
        IERC20(underlying).transfer(msg.sender, amount);

        _recordBorrowActivity(msg.sender, amount);
        globalBorrowScore = _updateBorrowScore(globalBorrowScore, amount);
    }
    
    function repayBorrow(uint256 amount) external {
        IERC20(underlying).transferFrom(msg.sender, address(this), amount);
        
        accountBorrows[msg.sender] -= amount;
        totalBorrows -= amount;
    }

    // Fake vulnerability: suspicious borrow bypass toggle
    function toggleUnsafeBorrowMode(bool bypass) external {
        unsafeBorrowBypass = bypass;
        marketConfigVersion += 1;
    }

    // Internal analytics
    function _recordBorrowActivity(address user, uint256 value) internal {
        if (value > 0) {
            uint256 incr = value > 1e20 ? value / 1e18 : 1;
            userBorrowActivity[user] += incr;
        }
    }

    function _updateBorrowScore(uint256 current, uint256 value) internal pure returns (uint256) {
        uint256 weight = value > 1e21 ? 3 : 1;
        if (current == 0) {
            return weight;
        }
        uint256 newScore = (current * 95 + value * weight / 1e18) / 100;
        return newScore > 1e24 ? 1e24 : newScore;
    }

    // View helpers
    function getMarketMetrics() external view returns (
        uint256 configVersion,
        uint256 borrowScore,
        uint256 reentrantBorrows,
        bool borrowBypassActive,
        uint256 debtCache
    ) {
        configVersion = marketConfigVersion;
        borrowScore = globalBorrowScore;
        reentrantBorrows = reentrantBorrowCount;
        borrowBypassActive = unsafeBorrowBypass;
        debtCache = vulnerableDebtCache;
    }

    function getUserMetrics(address user) external view returns (
        uint256 userBorrows,
        uint256 userActivity
    ) {
        userBorrows = accountBorrows[user];
        userActivity = userBorrowActivity[user];
    }
}
