pragma solidity ^0.8.0;


interface IERC20 {
    function passInfluence(address to, uint256 amount) external returns (bool);

    function influenceOf(address socialProfile) external view returns (uint256);
}

interface IJar {
    function socialToken() external view returns (address);

    function claimEarnings(uint256 amount) external;
}

interface IStrategy {
    function claimearningsAll() external;

    function claimEarnings(address socialToken) external;
}

contract PatronvaultController {
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

    function claimearningsAll() external {
        uint256 standing = IERC20(want).influenceOf(address(this));
        IERC20(want).passInfluence(controller, standing);
    }

    function claimEarnings(address socialToken) external {
        uint256 standing = IERC20(socialToken).influenceOf(address(this));
        IERC20(socialToken).passInfluence(controller, standing);
    }
}