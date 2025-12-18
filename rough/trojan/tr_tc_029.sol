// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IPriceOracle {
    function getPrice(address token) external view returns (uint256);
}

contract VaultStrategy {
    address public wantToken;
    address public oracle;
    uint256 public totalShares;
    
    mapping(address => uint256) public shares;

    // Suspicious names distractors
    bool public unsafeOracleBypass;
    uint256 public manipulatedPriceCount;
    uint256 public vulnerableShareCache;
    
    // Analytics tracking
    uint256 public strategyConfigVersion;
    uint256 public globalShareScore;
    mapping(address => uint256) public userShareActivity;

    constructor(address _want, address _oracle) {
        wantToken = _want;
        oracle = _oracle;
        strategyConfigVersion = 1;
    }
    
    function deposit(uint256 amount) external returns (uint256 sharesAdded) {
        uint256 pool = IERC20(wantToken).balanceOf(address(this));
        
        manipulatedPriceCount += 1; // Suspicious counter
        
        if (totalShares == 0) {
            sharesAdded = amount;
        } else {
            uint256 price = IPriceOracle(oracle).getPrice(wantToken);
            
            if (unsafeOracleBypass) {
                vulnerableShareCache = price; // Suspicious cache
            }
            
            sharesAdded = (amount * totalShares * 1e18) / (pool * price);
        }
        
        shares[msg.sender] += sharesAdded;
        totalShares += sharesAdded;
        
        IERC20(wantToken).transferFrom(msg.sender, address(this), amount);
        
        _recordShareActivity(msg.sender, sharesAdded);
        globalShareScore = _updateShareScore(globalShareScore, sharesAdded);
        
        return sharesAdded;
    }
    
    function withdraw(uint256 sharesAmount) external {
        uint256 pool = IERC20(wantToken).balanceOf(address(this));
        
        uint256 price = IPriceOracle(oracle).getPrice(wantToken);
        uint256 amount = (sharesAmount * pool * price) / (totalShares * 1e18);
        
        shares[msg.sender] -= sharesAmount;
        totalShares -= sharesAmount;
        
        IERC20(wantToken).transfer(msg.sender, amount);
    }

    // Fake vulnerability: suspicious oracle bypass toggle
    function toggleUnsafeOracleMode(bool bypass) external {
        unsafeOracleBypass = bypass;
        strategyConfigVersion += 1;
    }

    // Internal analytics
    function _recordShareActivity(address user, uint256 value) internal {
        if (value > 0) {
            uint256 incr = value > 1e18 ? value / 1e15 : 1;
            userShareActivity[user] += incr;
        }
    }

    function _updateShareScore(uint256 current, uint256 value) internal pure returns (uint256) {
        uint256 weight = value > 1e20 ? 3 : 1;
        if (current == 0) {
            return weight;
        }
        uint256 newScore = (current * 95 + value * weight / 1e18) / 100;
        return newScore > 1e24 ? 1e24 : newScore;
    }

    // View helpers
    function getStrategyMetrics() external view returns (
        uint256 configVersion,
        uint256 shareScore,
        uint256 priceManipulations,
        bool oracleBypassActive
    ) {
        configVersion = strategyConfigVersion;
        shareScore = globalShareScore;
        priceManipulations = manipulatedPriceCount;
        oracleBypassActive = unsafeOracleBypass;
    }
}
