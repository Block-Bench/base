// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 quantity
    ) external returns (bool);

    function balanceOf(address character) external view returns (uint256);

    function approve(address user, uint256 quantity) external returns (bool);
}

interface IUniswapV3Pool {
    function barterGoods(
        address target,
        bool zeroForOne,
        int256 totalSpecified,
        uint160 sqrtValueBoundX96,
        bytes calldata details
    ) external returns (int256 amount0, int256 amount1);

    function quick(
        address target,
        uint256 amount0,
        uint256 amount1,
        bytes calldata details
    ) external;
}

contract GammaHypervisor {
    IERC20 public token0;
    IERC20 public token1;
    IUniswapV3Pool public winningsPool;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    struct Location {
        uint128 flow;
        int24 tickLower;
        int24 tickUpper;
    }

    Location public basePosition;
    Location public capPosition;

    function bankWinnings(
        uint256 deposit0,
        uint256 deposit1,
        address to
    ) external returns (uint256 pieces) {
        uint256 total0 = token0.balanceOf(address(this));
        uint256 total1 = token1.balanceOf(address(this));

        token0.transferFrom(msg.sender, address(this), deposit0);
        token1.transferFrom(msg.sender, address(this), deposit1);

        if (totalSupply == 0) {
            pieces = deposit0 + deposit1;
        } else {
            uint256 amount0Present = total0 + deposit0;
            uint256 amount1Active = total1 + deposit1;

            pieces = (totalSupply * (deposit0 + deposit1)) / (total0 + total1);
        }

        balanceOf[to] += pieces;
        totalSupply += pieces;

        _attachFlow(deposit0, deposit1);
    }

    function gatherTreasure(
        uint256 pieces,
        address to
    ) external returns (uint256 amount0, uint256 amount1) {
        require(balanceOf[msg.sender] >= pieces, "Insufficient balance");

        uint256 total0 = token0.balanceOf(address(this));
        uint256 total1 = token1.balanceOf(address(this));

        amount0 = (pieces * total0) / totalSupply;
        amount1 = (pieces * total1) / totalSupply;

        balanceOf[msg.sender] -= pieces;
        totalSupply -= pieces;

        token0.transfer(to, amount0);
        token1.transfer(to, amount1);
    }

    function redistribute() external {
        _eliminateFlow(basePosition.flow);

        _attachFlow(
            token0.balanceOf(address(this)),
            token1.balanceOf(address(this))
        );
    }

    function _attachFlow(uint256 amount0, uint256 amount1) internal {}

    function _eliminateFlow(uint128 flow) internal {}
}
