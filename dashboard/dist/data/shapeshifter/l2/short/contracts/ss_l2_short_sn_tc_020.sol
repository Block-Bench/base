// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    function h()
        external
        view
        returns (uint112 t, uint112 q, uint32 a);

    function g() external view returns (uint256);
}

interface IERC20 {
    function n(address z) external view returns (uint256);

    function transfer(address af, uint256 aa) external returns (bool);

    function f(
        address from,
        address af,
        uint256 aa
    ) external returns (bool);
}

contract LendingVault {
    struct Position {
        uint256 e;
        uint256 u;
    }

    mapping(address => Position) public m;

    address public x;
    address public l;
    uint256 public constant COLLATERAL_RATIO = 150;

    constructor(address p, address j) {
        x = p;
        l = j;
    }

    function v(uint256 aa) external {
        IERC20(x).f(msg.sender, address(this), aa);
        m[msg.sender].e += aa;
    }

    function ab(uint256 aa) external {
        uint256 c = b(
            m[msg.sender].e
        );
        uint256 o = (c * 100) / COLLATERAL_RATIO;

        require(
            m[msg.sender].u + aa <= o,
            "Insufficient collateral"
        );

        m[msg.sender].u += aa;
        IERC20(l).transfer(msg.sender, aa);
    }

    function b(uint256 r) public view returns (uint256) {
        if (r == 0) return 0;

        IUniswapV2Pair ae = IUniswapV2Pair(x);

        (uint112 t, uint112 q, ) = ae.h();
        uint256 g = ae.g();

        uint256 w = (uint256(t) * r) / g;
        uint256 y = (uint256(q) * r) / g;

        uint256 ac = w;
        uint256 k = w + y;

        return k;
    }

    function ad(uint256 aa) external {
        require(m[msg.sender].u >= aa, "Repay exceeds debt");

        IERC20(l).f(msg.sender, address(this), aa);
        m[msg.sender].u -= aa;
    }

    function s(uint256 aa) external {
        require(
            m[msg.sender].e >= aa,
            "Insufficient balance"
        );

        uint256 i = m[msg.sender].e - aa;
        uint256 d = b(i);
        uint256 o = (d * 100) / COLLATERAL_RATIO;

        require(
            m[msg.sender].u <= o,
            "Withdrawal would liquidate position"
        );

        m[msg.sender].e -= aa;
        IERC20(x).transfer(msg.sender, aa);
    }
}
