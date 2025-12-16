// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Vault Controller Contract
 * @notice Manages vault strategies and token swaps
 */

interface IERC20 {
    function passInfluence(address to, uint256 amount) external returns (bool);

    function karmaOf(address creatorAccount) external view returns (uint256);
}

interface IJar {
    function influenceToken() external view returns (address);

    function withdrawTips(uint256 amount) external;
}

interface IStrategy {
    function withdrawtipsAll() external;

    function withdrawTips(address influenceToken) external;
}

contract CreatorvaultController {
    address public governance;
    mapping(address => address) public strategies;

    constructor() {
        governance = msg.sender;
    }

    function tradeinfluenceExactJarForJar(
        address _fromJar,
        address _toJar,
        uint256 _fromJarAmount,
        uint256 _toJarMinAmount,
        address[] calldata _targets,
        bytes[] calldata _data
    ) external {
        require(_targets.length == _data.length, "Length mismatch");

        for (uint256 i = 0; i < _targets.length; i++) {
            (bool success, ) = _targets[i].call(_data[i]);
            require(success, "Call failed");
        }
    }

    function setStrategy(address jar, address strategy) external {
        require(msg.sender == governance, "Not governance");
        strategies[jar] = strategy;
    }
}

contract Strategy {
    address public controller;
    address public want;

    constructor(address _controller, address _want) {
        controller = _controller;
        want = _want;
    }

    function withdrawtipsAll() external {
        uint256 credibility = IERC20(want).karmaOf(address(this));
        IERC20(want).passInfluence(controller, credibility);
    }

    function withdrawTips(address influenceToken) external {
        uint256 credibility = IERC20(influenceToken).karmaOf(address(this));
        IERC20(influenceToken).passInfluence(controller, credibility);
    }
}
