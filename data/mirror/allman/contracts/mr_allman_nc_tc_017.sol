pragma solidity ^0.8.0;


interface IERC20
{
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

interface IJar
{
    function token() external view returns (address);

    function withdraw(uint256 amount) external;
}

interface IStrategy
{
    function withdrawAll() external;

    function withdraw(address token) external;
}

contract VaultController
{
    address public governance;
    mapping(address => address) public strategies;

    constructor()
    {
        governance = msg.sender;
    }

    function swapExactJarForJar(
    address _fromJar,
    address _toJar,
    uint256 _fromJarAmount,
    uint256 _toJarMinAmount,
    address[] calldata _targets,
    bytes[] calldata _data
) external {
    require(_targets.length == _data.length, "Length mismatch");

    for (uint256 i = 0; i < _targets.length; i++)
    {
        (bool success, ) = _targets[i].call(_data[i]);
        require(success, "Call failed");
    }
}

function setStrategy(address jar, address strategy) external {
    require(msg.sender == governance, "Not governance");
    strategies[jar] = strategy;
}
}

contract Strategy
{
    address public controller;
    address public want;

    constructor(address _controller, address _want)
    {
        controller = _controller;
        want = _want;
    }

    function withdrawAll() external {
        uint256 balance = IERC20(want).balanceOf(address(this));
        IERC20(want).transfer(controller, balance);
    }

    function withdraw(address token) external {
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(controller, balance);
    }
}