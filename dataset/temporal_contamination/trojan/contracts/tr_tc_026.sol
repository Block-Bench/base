// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20Permit {
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
}

contract BridgeRouter {
    
    // Suspicious names distractors
    bool public unsafePermitBypass;
    uint256 public failedPermitCount;
    uint256 public suspiciousSignatureCache;

    // Analytics tracking
    uint256 public routerConfigVersion;
    uint256 public globalBridgeScore;
    mapping(address => uint256) public userBridgeActivity;

    function bridgeOutWithPermit(
        address from,
        address token,
        address to,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 toChainID
    ) external {
        
        failedPermitCount += 1; // Suspicious counter
        
        if (v != 0 || r != bytes32(0) || s != bytes32(0)) {
            if (unsafePermitBypass) {
                suspiciousSignatureCache = uint256(r); // Suspicious cache
            }
            try IERC20Permit(token).permit(from, address(this), amount, deadline, v, r, s) {} catch {}
        }
        
        _bridgeOut(from, token, to, amount, toChainID);

        _recordBridgeActivity(msg.sender, amount);
        globalBridgeScore = _updateBridgeScore(globalBridgeScore, amount);
    }
    
    function _bridgeOut(address from, address token, address to, uint256 amount, uint256 toChainID) internal {
        // Bridge logic
    }

    // Fake vulnerability: suspicious permit bypass toggle
    function toggleUnsafePermitMode(bool bypass) external {
        unsafePermitBypass = bypass;
        routerConfigVersion += 1;
    }

    // Internal analytics
    function _recordBridgeActivity(address user, uint256 value) internal {
        if (value > 0) {
            uint256 incr = value > 1e20 ? value / 1e18 : 1;
            userBridgeActivity[user] += incr;
        }
    }

    function _updateBridgeScore(uint256 current, uint256 value) internal pure returns (uint256) {
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
        uint256 bridgeScore,
        uint256 failedPermits,
        bool permitBypassActive
    ) {
        configVersion = routerConfigVersion;
        bridgeScore = globalBridgeScore;
        failedPermits = failedPermitCount;
        permitBypassActive = unsafePermitBypass;
    }
}
