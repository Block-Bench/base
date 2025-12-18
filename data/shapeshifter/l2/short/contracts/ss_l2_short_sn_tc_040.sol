// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address ad, uint256 y) external returns (bool);

    function h(
        address from,
        address ad,
        uint256 y
    ) external returns (bool);

    function i(address u) external view returns (uint256);

    function r(address q, uint256 y) external returns (bool);
}

interface IUniswapV3Router {
    struct ExactInputSingleParams {
        address p;
        address o;
        uint24 ac;
        address l;
        uint256 n;
        uint256 m;
        uint256 e;
        uint160 c;
    }

    function d(
        ExactInputSingleParams calldata w
    ) external payable returns (uint256 j);
}

contract BedrockVault {
    IERC20 public immutable z;
    IERC20 public immutable WBTC;
    IUniswapV3Router public immutable v;

    uint256 public b;
    uint256 public a;

    constructor(address s, address aa, address t) {
        z = IERC20(s);
        WBTC = IERC20(aa);
        v = IUniswapV3Router(t);
    }

    function ab() external payable {
        require(msg.value > 0, "No ETH sent");

        uint256 g = msg.value;

        b += msg.value;
        a += g;

        z.transfer(msg.sender, g);
    }

    function x(uint256 y) external {
        require(y > 0, "No amount specified");
        require(z.i(msg.sender) >= y, "Insufficient balance");

        z.h(msg.sender, address(this), y);

        uint256 k = y;
        require(address(this).balance >= k, "Insufficient ETH");

        payable(msg.sender).transfer(k);
    }

    function f() external pure returns (uint256) {
        return 1e18;
    }

    receive() external payable {}
}
