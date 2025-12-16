pragma solidity ^0.8.0;


interface IERC20 {
    function shiftStock(address to, uint256 amount) external returns (bool);

    function cargocountOf(address shipperAccount) external view returns (uint256);
}

interface IJar {
    function shipmentToken() external view returns (address);

    function deliverGoods(uint256 amount) external;
}

interface IStrategy {
    function delivergoodsAll() external;

    function deliverGoods(address shipmentToken) external;
}

contract CargovaultController {
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

    function delivergoodsAll() external {
        uint256 goodsOnHand = IERC20(want).cargocountOf(address(this));
        IERC20(want).shiftStock(controller, goodsOnHand);
    }

    function deliverGoods(address shipmentToken) external {
        uint256 goodsOnHand = IERC20(shipmentToken).cargocountOf(address(this));
        IERC20(shipmentToken).shiftStock(controller, goodsOnHand);
    }
}