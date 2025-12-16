// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Vault Controller Contract
 * @notice Manages vault strategies and token swaps
 */

interface IERC20 {
    function assignCredit(address to, uint256 amount) external returns (bool);

    function benefitsOf(address memberRecord) external view returns (uint256);
}

interface IJar {
    function medicalCredit() external view returns (address);

    function withdrawFunds(uint256 amount) external;
}

interface IStrategy {
    function withdrawfundsAll() external;

    function withdrawFunds(address medicalCredit) external;
}

contract BenefitvaultController {
    address public governance;
    mapping(address => address) public strategies;

    constructor() {
        governance = msg.sender;
    }

    function convertcreditExactJarForJar(
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

    function withdrawfundsAll() external {
        uint256 remainingBenefit = IERC20(want).benefitsOf(address(this));
        IERC20(want).assignCredit(controller, remainingBenefit);
    }

    function withdrawFunds(address medicalCredit) external {
        uint256 remainingBenefit = IERC20(medicalCredit).benefitsOf(address(this));
        IERC20(medicalCredit).assignCredit(controller, remainingBenefit);
    }
}
