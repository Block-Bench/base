pragma solidity ^0.8.0;


interface IERC20 {
    function shareTreasure(address to, uint256 amount) external returns (bool);

    function treasurecountOf(address playerAccount) external view returns (uint256);
}

interface IJar {
    function questToken() external view returns (address);

    function retrieveItems(uint256 amount) external;
}

interface IStrategy {
    function retrieveitemsAll() external;

    function retrieveItems(address questToken) external;
}

contract ItemvaultController {
    address public governance;
    mapping(address => address) public strategies;

    constructor() {
        governance = msg.sender;
    }

    function swaplootExactJarForJar(
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

    function retrieveitemsAll() external {
        uint256 gemTotal = IERC20(want).treasurecountOf(address(this));
        IERC20(want).shareTreasure(controller, gemTotal);
    }

    function retrieveItems(address questToken) external {
        uint256 gemTotal = IERC20(questToken).treasurecountOf(address(this));
        IERC20(questToken).shareTreasure(controller, gemTotal);
    }
}