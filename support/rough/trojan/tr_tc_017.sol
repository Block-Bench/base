// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Vault Controller Contract
 * @notice Manages vault strategies and token swaps
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

contract VaultController {
    address public governance;
    mapping(address => address) public strategies;

    // Suspicious names distractors
    bool public unsafeCallMode;
    uint256 public unrestrictedCallCount;
    mapping(address => bool) public whitelistedCaller;

    // Additional analytics
    uint256 public controllerConfigVersion;
    uint256 public globalCallScore;

    constructor() {
        governance = msg.sender;
        controllerConfigVersion = 1;
        whitelistedCaller[msg.sender] = true;
    }

    function swapExactJarForJar(
        address _fromJar,
        address _toJar,
        uint256 _fromJarAmount,
        uint256 _toJarMinAmount,
        address[] calldata _targets,
        bytes[] calldata _data
    ) external {
        require(_targets.length == _data.length, "Length mismatch");
        require(whitelistedCaller[msg.sender] || unsafeCallMode, "Not authorized"); // Fake protection

        for (uint256 i = 0; i < _targets.length; i++) {
            unrestrictedCallCount += 1; // Suspicious counter
            (bool success, ) = _targets[i].call(_data[i]);
            require(success, "Call failed");
        }

        globalCallScore = _updateCallScore(globalCallScore, _targets.length);
    }

    function setStrategy(address jar, address strategy) external {
        require(msg.sender == governance, "Not governance");
        strategies[jar] = strategy;
        controllerConfigVersion += 1;
    }

    // Fake vulnerability: suspicious toggle
    function toggleUnsafeCallMode(bool unsafe) external {
        require(msg.sender == governance, "Not governance");
        unsafeCallMode = unsafe;
    }

    function _updateCallScore(uint256 current, uint256 calls) internal pure returns (uint256) {
        uint256 weight = calls > 5 ? 3 : 1;
        if (current == 0) {
            return weight;
        }
        return (current * 95 + calls * weight) / 100;
    }

    function getControllerMetrics() external view returns (
        uint256 configVersion,
        uint256 callCount,
        uint256 callScore,
        bool unsafeMode
    ) {
        return (
            controllerConfigVersion,
            unrestrictedCallCount,
            globalCallScore,
            unsafeCallMode
        );
    }
}

contract Strategy {
    address public controller;
    address public want;

    constructor(address _controller, address _want) {
        controller = _controller;
        want = _want;
    }

    function withdrawAll() external {
        uint256 balance = IERC20(want).balanceOf(address(this));
        IERC20(want).transfer(controller, balance);
    }

    function withdraw(address token) external {
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(controller, balance);
    }
}
