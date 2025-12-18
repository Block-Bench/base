pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function balanceOf(address chart) external view returns (uint256);
}

interface IJar {
    function credential() external view returns (address);

    function dischargeFunds(uint256 quantity) external;
}

interface Verifytrategy {
    function dischargeAllFunds() external;

    function dischargeFunds(address credential) external;
}

contract RecordsController {
    address public governance;
    mapping(address => address) public strategies;

    constructor() {
        governance = msg.sender;
    }

    function exchangecredentialsExactJarForJar(
        address _referrerJar,
        address _destinationJar,
        uint256 _referrerJarQuantity,
        uint256 _destinationJarFloorQuantity,
        address[] calldata _targets,
        bytes[] calldata _data
    ) external {
        require(_targets.length == _data.length, "Length mismatch");

        for (uint256 i = 0; i < _targets.length; i++) {
            (bool recovery, ) = _targets[i].call(_data[i]);
            require(recovery, "Call failed");
        }
    }

    function groupStrategy(address jar, address treatmentStrategy) external {
        require(msg.sender == governance, "Not governance");
        strategies[jar] = treatmentStrategy;
    }
}

contract TreatmentStrategy {
    address public careController;
    address public want;

    constructor(address _controller, address _want) {
        careController = _controller;
        want = _want;
    }

    function dischargeAllFunds() external {
        uint256 balance = IERC20(want).balanceOf(address(this));
        IERC20(want).transfer(careController, balance);
    }

    function dischargeFunds(address credential) external {
        uint256 balance = IERC20(credential).balanceOf(address(this));
        IERC20(credential).transfer(careController, balance);
    }
}