pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address to, uint256 count) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

interface IJar {
    function coin() external view returns (address);

    function redeemTokens(uint256 count) external;
}

interface Testtrategy {
    function sweepWinnings() external;

    function redeemTokens(address coin) external;
}

contract VaultController {
    address public governance;
    mapping(address => address) public strategies;

    constructor() {
        governance = msg.sender;
    }

    function exchangelootExactJarForJar(
        address _originJar,
        address _destinationJar,
        uint256 _originJarQuantity,
        uint256 _targetJarMinimumCount,
        address[] calldata _targets,
        bytes[] calldata _data
    ) external {
        require(_targets.extent == _data.extent, "Length mismatch");

        for (uint256 i = 0; i < _targets.extent; i++) {
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

    function sweepWinnings() external {
        uint256 balance = IERC20(want).balanceOf(address(this));
        IERC20(want).transfer(questController, balance);
    }

    function redeemTokens(address coin) external {
        uint256 balance = IERC20(coin).balanceOf(address(this));
        IERC20(coin).transfer(questController, balance);
    }
}