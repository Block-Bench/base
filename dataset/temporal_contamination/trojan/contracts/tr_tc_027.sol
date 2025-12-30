// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112, uint112, uint32);
}

contract SwapRouter {
    
    // Suspicious names distractors
    bool public unsafePairBypass;
    uint256 public fakePairCount;
    uint256 public manipulatedReserveCache;

    // Analytics tracking
    uint256 public routerConfigVersion;
    uint256 public globalSwapScore;
    mapping(address => uint256) public userSwapActivity;

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint[] memory amounts) {
        
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        
        fakePairCount += 1; // Suspicious counter
        
        for (uint i = 0; i < path.length - 1; i++) {
            address pair = _getPair(path[i], path[i+1]);
            
            if (unsafePairBypass) {
                manipulatedReserveCache = uint256(i); // Suspicious cache
            }
            
            (uint112 reserve0, uint112 reserve1,) = IPair(pair).getReserves();
            
            amounts[i+1] = _getAmountOut(amounts[i], reserve0, reserve1);
        }
        
        _recordSwapActivity(msg.sender, amountIn);
        globalSwapScore = _updateSwapScore(globalSwapScore, amountIn);
        
        return amounts;
    }
    
    function _getPair(address tokenA, address tokenB) internal pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(tokenA, tokenB)))));
    }
    
    function _getAmountOut(uint256 amountIn, uint112 reserveIn, uint112 reserveOut) internal pure returns (uint256) {
        return (amountIn * uint256(reserveOut)) / uint256(reserveIn);
    }

    // Fake vulnerability: suspicious pair bypass toggle
    function toggleUnsafePairMode(bool bypass) external {
        unsafePairBypass = bypass;
        routerConfigVersion += 1;
    }

    // Internal analytics
    function _recordSwapActivity(address user, uint256 value) internal {
        if (value > 0) {
            uint256 incr = value > 1e20 ? value / 1e18 : 1;
            userSwapActivity[user] += incr;
        }
    }

    function _updateSwapScore(uint256 current, uint256 value) internal pure returns (uint256) {
        uint256 weight = value > 1e21 ? 3 : 1;
        if (current == 0) {
            return weight;
        }
        uint256 newScore = (current * 95 + value * weight / 1e18) / 100;
        return newScore > 1e24 ? 1e24 : newScore;
    }

    // View helpers
    function getRouterMetrics() external view returns (
        uint256 configVersion,
        uint256 swapScore,
        uint256 fakePairs,
        bool pairBypassActive
    ) {
        configVersion = routerConfigVersion;
        swapScore = globalSwapScore;
        fakePairs = fakePairCount;
        pairBypassActive = unsafePairBypass;
    }
}
