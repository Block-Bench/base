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

contract PickleController {
    address public governance;
    mapping(address => address) public strategies;
    mapping(address => bool) public validTargets;

    constructor() {
        governance = msg.sender;
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

        for (uint256 i = 0; i < _targets.length; i++) {
            require(validTargets[_targets[i]], "Target not allowed");
            (bool success, ) = _targets[i].call(_data[i]);
            require(success, "Call failed");
        }
    }

    function setStrategy(address jar, address strategy) external {
        require(msg.sender == governance, "Not governance");
        strategies[jar] = strategy;
    }

    function addValidTarget(address target) external {
        require(msg.sender == governance, "Not governance");
        validTargets[target] = true;
    }
}

contract PickleStrategy {
    address public controller;
    address public want;

    constructor(address _controller, address _want) {
        controller = _controller;
        want = _want;
    }

    function withdrawAll() external {
        require(msg.sender == controller, "Not controller");
        uint256 balance = IERC20(want).balanceOf(address(this));
        IERC20(want).transfer(controller, balance);
    }

    function withdraw(address token) external {
        require(msg.sender == controller, "Not controller");
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(controller, balance);
    }
}
