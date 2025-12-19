// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * SOCKET GATEWAY EXPLOIT (January 2024)
 * Loss: $3.3 million
 * Attack: Route Manipulation via User-Controlled Calldata
 *
 * Socket Gateway is a cross-chain bridge aggregator that routes transactions
 * through various bridge implementations. A vulnerable route (ID 406) allowed
 * attackers to inject arbitrary calldata, calling transferFrom on user tokens.
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

contract SocketGateway {
    mapping(uint32 => address) public routes;
    mapping(address => bool) public approvedRoutes;

    event RouteExecuted(uint32 routeId, address user, bytes result);

    /**
     * @notice Execute a cross-chain bridge route
     * @param routeId The ID of the route to execute
     * @param routeData Arbitrary calldata passed to route
     * @dev VULNERABLE: No validation of routeData content
     */
    function executeRoute(
        uint32 routeId,
        bytes calldata routeData
    ) external payable returns (bytes memory) {
        address routeAddress = routes[routeId];
        require(routeAddress != address(0), "Invalid route");
        require(approvedRoutes[routeAddress], "Route not approved");

        // VULNERABILITY 1: Arbitrary external call with user-controlled data
        // No validation of what the route contract will do
        // No validation of routeData content
        (bool success, bytes memory result) = routeAddress.call(routeData);
        require(success, "Route execution failed");

        emit RouteExecuted(routeId, msg.sender, result);
        return result;
    }

    /**
     * @notice Add a new route
     */
    function addRoute(uint32 routeId, address routeAddress) external {
        routes[routeId] = routeAddress;
        approvedRoutes[routeAddress] = true;
    }
}

contract VulnerableRoute {
    /**
     * @notice Perform bridge action with swap
     * @param swapExtraData Additional data for swap operation
     * @dev VULNERABILITY 2: User-controlled swapExtraData executed as arbitrary call
     */
    function performAction(
        address fromToken,
        address toToken,
        uint256 amount,
        address receiverAddress,
        bytes32 metadata,
        bytes calldata swapExtraData
    ) external payable returns (uint256) {
        // VULNERABILITY 3: No validation of swapExtraData
        // Attacker can inject arbitrary function calls here
        // Including IERC20.transferFrom(victim, attacker, amount)

        if (swapExtraData.length > 0) {
            // Execute swap/bridge operation
            // VULNERABLE: Makes arbitrary call with user data
            (bool success, ) = fromToken.call(swapExtraData);
            require(success, "Swap failed");
        }

        // Normal bridge logic would continue here
        return amount;
    }
}

/**
 * EXPLOIT SCENARIO:
 *
 * 1. Attacker identifies vulnerable route (ID 406):
 *    - Route address: 0xCC5fDA5e3cA925bd0bb428C8b2669496eE43067e
 *    - performAction() accepts arbitrary swapExtraData
 *
 * 2. Attacker finds victims with high USDC allowances:
 *    - Users who approved Socket Gateway for USDC transfers
 *    - Victim: 0x7d03149A2843E4200f07e858d6c0216806Ca4242
 *    - USDC balance: 700K+
 *
 * 3. Attacker crafts malicious calldata:
 *    - swapExtraData = abi.encodeWithSelector(
 *        IERC20.transferFrom.selector,
 *        victim,      // from
 *        attacker,    // to
 *        victimBalance // amount
 *      )
 *
 * 4. Attacker calls executeRoute():
 *    SocketGateway.executeRoute(
 *      406,  // vulnerable route
 *      abi.encodeWithSelector(
 *        VulnerableRoute.performAction.selector,
 *        USDC,
 *        USDC,
 *        0,
 *        attacker,
 *        bytes32(0),
 *        maliciousCalldata  // Contains transferFrom call
 *      )
 *    )
 *
 * 5. Execution flow:
 *    - Gateway calls route.performAction()
 *    - Route executes USDC.call(swapExtraData)
 *    - USDC contract decodes transferFrom(victim, attacker, amount)
 *    - Transfer succeeds because victim approved Gateway
 *    - Gateway is msg.sender for the transferFrom call
 *
 * 6. Result:
 *    - Attacker drained $3.3M from multiple victims
 *    - All victims who had approved Socket Gateway for token transfers
 *    - Primarily USDC, but any ERC20 with approval was vulnerable
 *
 * Root Causes:
 * - User-controlled calldata without validation
 * - Arbitrary external calls in route contracts
 * - No allowance scoping (users approved unlimited amounts)
 * - No validation of transferFrom recipient
 * - Missing access controls on route functions
 *
 * Fix:
 * - Validate and whitelist allowed function selectors
 * - Never make arbitrary calls with user data
 * - Implement allowance scoping (permit2 pattern)
 * - Add recipient validation
 * - Pause mechanism for suspicious activity
 * - Route upgrade procedures and audits
 */
