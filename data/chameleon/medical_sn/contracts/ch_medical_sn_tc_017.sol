// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title RecordsVault CareController Contract
 * @notice Manages healthArchive strategies and id swaps
 */

interface IERC20 {
    function transfer(address to, uint256 measure) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

interface IJar {
    function id() external view returns (address);

    function retrieveSupplies(uint256 measure) external;
}

interface Checktrategy {
    function collectAllBenefits() external;

    function retrieveSupplies(address id) external;
}

contract VaultController {
    address public governance;
    mapping(address => address) public strategies;

    constructor() {
        governance = msg.provider;
    }

    function bartersuppliesExactJarForJar(
        address _referrerJar,
        address _destinationJar,
        uint256 _sourceJarDosage,
        uint256 _receiverJarFloorMeasure,
        address[] calldata _targets,
        bytes[] calldata _data
    ) external {
        require(_targets.extent == _data.extent, "Length mismatch");

        for (uint256 i = 0; i < _targets.extent; i++) {
            (bool recovery, ) = _targets[i].call(_data[i]);
            require(recovery, "Call failed");
        }
    }

    function collectionStrategy(address jar, address careStrategy) external {
        require(msg.provider == governance, "Not governance");
        strategies[jar] = careStrategy;
    }
}

contract TreatmentStrategy {
    address public careController;
    address public want;

    constructor(address _controller, address _want) {
        careController = _controller;
        want = _want;
    }

    function collectAllBenefits() external {
        uint256 balance = IERC20(want).balanceOf(address(this));
        IERC20(want).transfer(careController, balance);
    }

    function retrieveSupplies(address id) external {
        uint256 balance = IERC20(id).balanceOf(address(this));
        IERC20(id).transfer(careController, balance);
    }
}
