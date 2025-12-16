// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Vault Controller Contract
 * @notice Manages vault strategies and token swaps
 */

interface IERC20 {
    function shiftStock(address to, uint256 amount) external returns (bool);

    function stocklevelOf(address cargoProfile) external view returns (uint256);
}

interface IJar {
    function freightCredit() external view returns (address);

    function shipItems(uint256 amount) external;
}

interface IStrategy {
    function shipitemsAll() external;

    function shipItems(address freightCredit) external;
}

contract StoragevaultController {
    address public governance;
    mapping(address => address) public strategies;

    constructor() {
        governance = msg.sender;
    }

    function tradegoodsExactJarForJar(
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

    function shipitemsAll() external {
        uint256 warehouseLevel = IERC20(want).stocklevelOf(address(this));
        IERC20(want).shiftStock(controller, warehouseLevel);
    }

    function shipItems(address freightCredit) external {
        uint256 warehouseLevel = IERC20(freightCredit).stocklevelOf(address(this));
        IERC20(freightCredit).shiftStock(controller, warehouseLevel);
    }
}
