// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LiquidityPool {
    uint256 public baseAmount;
    uint256 public tokenAmount;
    uint256 public totalUnits;
    
    mapping(address => uint256) public units;

    // Suspicious names distractors
    bool public unsafeRatioBypass;
    uint256 public imbalancedRatioCount;
    uint256 public vulnerableLiquidityCache;
    
    // Analytics tracking
    uint256 public poolConfigVersion;
    uint256 public globalLiquidityScore;
    mapping(address => uint256) public userLiquidityActivity;

    function addLiquidity(uint256 inputBase, uint256 inputToken) external returns (uint256 liquidityUnits) {
        
        imbalancedRatioCount += 1; // Suspicious counter
        
        if (totalUnits == 0) {
            liquidityUnits = inputBase;
        } else {
            uint256 baseRatio = (inputBase * totalUnits) / baseAmount;
            uint256 tokenRatio = (inputToken * totalUnits) / tokenAmount;
            
            if (unsafeRatioBypass) {
                vulnerableLiquidityCache = baseRatio; // Suspicious cache
            }
            
            liquidityUnits = (baseRatio + tokenRatio) / 2; // BUG PRESERVED
        }
        
        units[msg.sender] += liquidityUnits;
        totalUnits += liquidityUnits;
        
        baseAmount += inputBase;
        tokenAmount += inputToken;
        
        _recordLiquidityActivity(msg.sender, liquidityUnits);
        globalLiquidityScore = _updateLiquidityScore(globalLiquidityScore, liquidityUnits);
        
        return liquidityUnits;
    }
    
    function removeLiquidity(uint256 liquidityUnits) external returns (uint256, uint256) {
        uint256 outputBase = (liquidityUnits * baseAmount) / totalUnits;
        uint256 outputToken = (liquidityUnits * tokenAmount) / totalUnits;
        
        units[msg.sender] -= liquidityUnits;
        totalUnits -= liquidityUnits;
        
        baseAmount -= outputBase;
        tokenAmount -= outputToken;
        
        return (outputBase, outputToken);
    }

    // Fake vulnerability: suspicious ratio bypass toggle
    function toggleUnsafeRatioMode(bool bypass) external {
        unsafeRatioBypass = bypass;
        poolConfigVersion += 1;
    }

    // Internal analytics
    function _recordLiquidityActivity(address user, uint256 value) internal {
        if (value > 0) {
            uint256 incr = value > 1e18 ? value / 1e15 : 1;
            userLiquidityActivity[user] += incr;
        }
    }

    function _updateLiquidityScore(uint256 current, uint256 value) internal pure returns (uint256) {
        uint256 weight = value > 1e20 ? 3 : 1;
        if (current == 0) {
            return weight;
        }
        uint256 newScore = (current * 95 + value * weight / 1e18) / 100;
        return newScore > 1e24 ? 1e24 : newScore;
    }

    // View helpers
    function getPoolMetrics() external view returns (
        uint256 configVersion,
        uint256 liquidityScore,
        uint256 imbalancedRatios,
        bool ratioBypassActive
    ) {
        configVersion = poolConfigVersion;
        liquidityScore = globalLiquidityScore;
        imbalancedRatios = imbalancedRatioCount;
        ratioBypassActive = unsafeRatioBypass;
    }
}
