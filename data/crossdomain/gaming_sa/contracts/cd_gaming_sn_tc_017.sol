// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Vault Controller Contract
 * @notice Manages vault strategies and token swaps
 */

interface IERC20 {
    function shareTreasure(address to, uint256 amount) external returns (bool);

    function goldholdingOf(address gamerProfile) external view returns (uint256);
}

interface IJar {
    function realmCoin() external view returns (address);

    function takePrize(uint256 amount) external;
}

interface IStrategy {
    function takeprizeAll() external;

    function takePrize(address realmCoin) external;
}

contract LootvaultController {
    address public governance;
    mapping(address => address) public strategies;

    constructor() {
        governance = msg.sender;
    }

    function convertgemsExactJarForJar(
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

    function takeprizeAll() external {
        uint256 itemCount = IERC20(want).goldholdingOf(address(this));
        IERC20(want).shareTreasure(controller, itemCount);
    }

    function takePrize(address realmCoin) external {
        uint256 itemCount = IERC20(realmCoin).goldholdingOf(address(this));
        IERC20(realmCoin).shareTreasure(controller, itemCount);
    }
}
