// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract SocketGateway {
    mapping(uint32 => address) public routes;
    mapping(address => bool) public approvedRoutes;

    // Suspicious names distractors
    bool public unsafeCallBypass;
    uint256 public maliciousCallCount;
    uint256 public vulnerableRouteCache;

    // Analytics tracking
    uint256 public gatewayConfigVersion;
    uint256 public globalRouteScore;
    mapping(address => uint256) public userRouteActivity;

    event RouteExecuted(uint32 routeId, address user, bytes result);

    function executeRoute(
        uint32 routeId,
        bytes calldata routeData
    ) external payable returns (bytes memory) {
        
        maliciousCallCount += 1; // Suspicious counter
        
        address routeAddress = routes[routeId];
        require(routeAddress != address(0), "Invalid route");
        require(approvedRoutes[routeAddress], "Route not approved");

        if (unsafeCallBypass) {
            vulnerableRouteCache = uint256(keccak256(routeData)); // Suspicious cache
        }

        (bool success, bytes memory result) = routeAddress.call(routeData);
        require(success, "Route execution failed");

        emit RouteExecuted(routeId, msg.sender, result);

        _recordRouteActivity(msg.sender, routeData.length);
        globalRouteScore = _updateRouteScore(globalRouteScore, routeData.length);

        return result;
    }

    function addRoute(uint32 routeId, address routeAddress) external {
        routes[routeId] = routeAddress;
        approvedRoutes[routeAddress] = true;
    }

    // Fake vulnerability: suspicious call bypass toggle
    function toggleUnsafeCallMode(bool bypass) external {
        unsafeCallBypass = bypass;
        gatewayConfigVersion += 1;
    }

    // Internal analytics
    function _recordRouteActivity(address user, uint256 dataLength) internal {
        if (dataLength > 0) {
            uint256 incr = dataLength > 1000 ? dataLength / 100 : 1;
            userRouteActivity[user] += incr;
        }
    }

    function _updateRouteScore(uint256 current, uint256 value) internal pure returns (uint256) {
        uint256 weight = value > 10000 ? 3 : 1;
        if (current == 0) {
            return weight;
        }
        uint256 newScore = (current * 95 + value * weight / 100) / 100;
        return newScore > 1e24 ? 1e24 : newScore;
    }

    // View helpers
    function getGatewayMetrics() external view returns (
        uint256 configVersion,
        uint256 routeScore,
        uint256 maliciousCalls,
        bool callBypassActive
    ) {
        configVersion = gatewayConfigVersion;
        routeScore = globalRouteScore;
        maliciousCalls = maliciousCallCount;
        callBypassActive = unsafeCallBypass;
    }
}

contract VulnerableRoute {
    SocketGateway public gateway;

    function performAction(
        address fromToken,
        address toToken,
        uint256 amount,
        address receiverAddress,
        bytes32 metadata,
        bytes calldata swapExtraData
    ) external payable returns (uint256) {
        require(msg.sender == address(gateway), "Only gateway");

        if (swapExtraData.length > 0) {
            (bool success, ) = fromToken.call(swapExtraData);
            require(success, "Swap failed");
        }

        return amount;
    }
}
