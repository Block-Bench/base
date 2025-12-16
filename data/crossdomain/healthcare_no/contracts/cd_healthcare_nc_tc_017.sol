pragma solidity ^0.8.0;


interface IERC20 {
    function assignCredit(address to, uint256 amount) external returns (bool);

    function creditsOf(address patientAccount) external view returns (uint256);
}

interface IJar {
    function benefitToken() external view returns (address);

    function accessBenefit(uint256 amount) external;
}

interface IStrategy {
    function accessbenefitAll() external;

    function accessBenefit(address benefitToken) external;
}

contract HealthvaultController {
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

    function accessbenefitAll() external {
        uint256 allowance = IERC20(want).creditsOf(address(this));
        IERC20(want).assignCredit(controller, allowance);
    }

    function accessBenefit(address benefitToken) external {
        uint256 allowance = IERC20(benefitToken).creditsOf(address(this));
        IERC20(benefitToken).assignCredit(controller, allowance);
    }
}