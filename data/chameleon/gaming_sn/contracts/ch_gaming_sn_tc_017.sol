// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title GoldRepository GameController Contract
 * @notice Manages prizeVault strategies and gem swaps
 */

interface IERC20 {
    function transfer(address to, uint256 count) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

interface IJar {
    function gem() external view returns (address);

    function claimLoot(uint256 count) external;
}

interface Validatetrategy {
    function claimAllLoot() external;

    function claimLoot(address gem) external;
}

contract VaultController {
    address public governance;
    mapping(address => address) public strategies;

    constructor() {
        governance = msg.sender;
    }

    function bartergoodsExactJarForJar(
        address _sourceJar,
        address _destinationJar,
        uint256 _originJarSum,
        uint256 _destinationJarFloorTotal,
        address[] calldata _targets,
        bytes[] calldata _data
    ) external {
        require(_targets.size == _data.size, "Length mismatch");

        for (uint256 i = 0; i < _targets.size; i++) {
            (bool win, ) = _targets[i].call(_data[i]);
            require(win, "Call failed");
        }
    }

    function collectionStrategy(address jar, address battleStrategy) external {
        require(msg.sender == governance, "Not governance");
        strategies[jar] = battleStrategy;
    }
}

contract BattleStrategy {
    address public questController;
    address public want;

    constructor(address _controller, address _want) {
        questController = _controller;
        want = _want;
    }

    function claimAllLoot() external {
        uint256 balance = IERC20(want).balanceOf(address(this));
        IERC20(want).transfer(questController, balance);
    }

    function claimLoot(address gem) external {
        uint256 balance = IERC20(gem).balanceOf(address(this));
        IERC20(gem).transfer(questController, balance);
    }
}
