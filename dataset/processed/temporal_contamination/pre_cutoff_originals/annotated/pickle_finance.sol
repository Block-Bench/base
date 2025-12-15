// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Pickle Finance - Arbitrary Call Vulnerability
 * @notice This contract demonstrates the vulnerability that led to the Pickle hack
 * @dev November 21, 2020 - $20M stolen through arbitrary contract calls
 *
 * VULNERABILITY: Arbitrary external calls in swap function allowing malicious operations
 *
 * ROOT CAUSE:
 * The Controller's swapExactJarForJar() function accepts arrays of target addresses
 * and calldata, then makes arbitrary external calls to these targets. An attacker
 * can craft malicious calldata that calls privileged functions on strategy contracts,
 * such as withdrawAll() or withdraw(), draining funds.
 *
 * ATTACK VECTOR:
 * 1. Create fake "jar" (vault) contracts that return attacker-controlled addresses
 * 2. Call swapExactJarForJar() with these fake jars
 * 3. Pass target addresses pointing to real strategy contracts
 * 4. Pass calldata that encodes calls to withdrawAll() or other privileged functions
 * 5. Controller makes these calls without proper authorization checks
 * 6. Strategy contracts execute withdrawAll(), sending funds to attacker
 * 7. Repeat with multiple strategies to drain protocol
 *
 * The vulnerability is that the Controller trusts user-provided targets and calldata
 * without validating what functions are being called or who should be able to call them.
 */

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

interface IJar {
    function token() external view returns (address);

    function withdraw(uint256 amount) external;
}

interface IStrategy {
    function withdrawAll() external;

    function withdraw(address token) external;
}

contract VulnerablePickleController {
    address public governance;
    mapping(address => address) public strategies; // jar => strategy

    constructor() {
        governance = msg.sender;
    }

    /**
     * @notice Swap tokens between jars through strategies
     * @param _fromJar Source jar address
     * @param _toJar Destination jar address
     * @param _fromJarAmount Amount to swap
     * @param _toJarMinAmount Minimum amount to receive
     * @param _targets Array of target contract addresses to call
     * @param _data Array of calldata for each target
     *
     * VULNERABILITY IS HERE:
     * The function makes arbitrary calls to user-provided targets with user-provided data.
     * There are no checks on:
     * 1. What contracts can be called (_targets)
     * 2. What functions can be called (encoded in _data)
     * 3. Whether the caller should have permission to make these calls
     *
     * Vulnerable sequence:
     * 1. Function accepts arbitrary _targets and _data arrays (line 81-82)
     * 2. Loops through and calls each target (line 88-91)
     * 3. No validation of targets or data
     * 4. Attacker can call withdrawAll() on strategies
     * 5. Attacker can call any function on any contract
     * 6. Funds drained from strategies
     */
    function swapExactJarForJar(
        address _fromJar,
        address _toJar,
        uint256 _fromJarAmount,
        uint256 _toJarMinAmount,
        address[] calldata _targets,
        bytes[] calldata _data
    ) external {
        require(_targets.length == _data.length, "Length mismatch");

        // VULNERABLE: Make arbitrary calls without validation
        for (uint256 i = 0; i < _targets.length; i++) {
            (bool success, ) = _targets[i].call(_data[i]);
            require(success, "Call failed");
        }

        // The rest of swap logic would go here
        // But it doesn't matter because attacker already drained funds
    }

    /**
     * @notice Set strategy for a jar
     * @dev Only governance should call this
     */
    function setStrategy(address jar, address strategy) external {
        require(msg.sender == governance, "Not governance");
        strategies[jar] = strategy;
    }
}

/**
 * Example Strategy contract that can be exploited:
 */
contract PickleStrategy {
    address public controller;
    address public want; // The token this strategy manages

    constructor(address _controller, address _want) {
        controller = _controller;
        want = _want;
    }

    /**
     * @notice Withdraw all funds from strategy
     * @dev Should only be callable by controller, but no check!
     */
    function withdrawAll() external {
        // VULNERABLE: No access control!
        // Should check: require(msg.sender == controller, "Not controller");

        uint256 balance = IERC20(want).balanceOf(address(this));
        IERC20(want).transfer(controller, balance);
    }

    /**
     * @notice Withdraw specific token
     * @dev Also lacks access control
     */
    function withdraw(address token) external {
        // VULNERABLE: No access control!
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(controller, balance);
    }
}

/**
 * Example attack flow:
 *
 * 1. Attacker creates FakeJar contract:
 *    contract FakeJar {
 *        address public token;
 *        constructor(address _token) { token = _token; }
 *    }
 *
 * 2. Attacker encodes malicious calldata:
 *    bytes memory withdrawAllData = abi.encodeWithSignature("withdrawAll()");
 *    bytes memory withdrawData = abi.encodeWithSignature("withdraw(address)", DAI_ADDRESS);
 *
 * 3. Attacker calls controller.swapExactJarForJar():
 *    - _fromJar = address(fakeJar1)
 *    - _toJar = address(fakeJar2)
 *    - _fromJarAmount = 0
 *    - _toJarMinAmount = 0
 *    - _targets = [strategyAddress1, strategyAddress2, ...]
 *    - _data = [withdrawAllData, withdrawData, ...]
 *
 * 4. Controller calls strategy.withdrawAll() on behalf of attacker
 * 5. Strategy sends all funds to controller (which is compromised in this flow)
 * 6. Attacker repeats for all strategies
 * 7. $20M drained
 *
 * REAL-WORLD IMPACT:
 * - $20M stolen in November 2020
 * - DAI strategy completely drained
 * - Demonstrated danger of arbitrary external calls
 * - Led to stricter function access controls in DeFi
 *
 * FIX:
 * 1. Remove arbitrary call functionality entirely:
 *
 * function swapExactJarForJar(
 *     address _fromJar,
 *     address _toJar,
 *     uint256 _fromJarAmount,
 *     uint256 _toJarMinAmount
 * ) external {
 *     // Implement swap logic directly, no arbitrary calls
 *     address fromStrategy = strategies[_fromJar];
 *     address toStrategy = strategies[_toJar];
 *
 *     // Call specific, known functions only
 *     IStrategy(fromStrategy).withdraw(_fromJarAmount);
 *     IStrategy(toStrategy).deposit(_fromJarAmount);
 * }
 *
 * 2. Add strict access control to strategy functions:
 *
 * function withdrawAll() external {
 *     require(msg.sender == controller, "Only controller");
 *     uint256 balance = IERC20(want).balanceOf(address(this));
 *     IERC20(want).transfer(controller, balance);
 * }
 *
 * 3. Whitelist allowed targets and function selectors:
 *
 * mapping(address => mapping(bytes4 => bool)) public allowedCalls;
 *
 * function swapExactJarForJar(...) external {
 *     for (uint256 i = 0; i < _targets.length; i++) {
 *         bytes4 selector = bytes4(_data[i]);
 *         require(allowedCalls[_targets[i]][selector], "Call not allowed");
 *         (bool success, ) = _targets[i].call(_data[i]);
 *         require(success, "Call failed");
 *     }
 * }
 *
 * VULNERABLE LINES:
 * - Line 88-91: Arbitrary external calls without validation
 * - Line 118-122: withdrawAll() lacks access control
 * - Line 128-131: withdraw() lacks access control
 *
 * KEY LESSON:
 * Never allow arbitrary external calls with user-provided targets and calldata.
 * Always validate what contracts and functions can be called.
 * Implement strict access control on all privileged functions.
 * If arbitrary calls are needed, use strict whitelisting.
 */
