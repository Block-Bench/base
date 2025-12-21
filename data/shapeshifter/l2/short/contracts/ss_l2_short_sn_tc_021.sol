// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function s(address x) external view returns (uint256);

    function transfer(address af, uint256 z) external returns (bool);

    function f(
        address from,
        address af,
        uint256 z
    ) external returns (bool);
}

contract LiquidityPool {
    address public k;
    address public t;
    address public m;

    uint256 public r;
    uint256 public g;
    uint256 public e;

    bool public c;

    event Initialized(address k, address ac, address aa);

    function ad(
        address h,
        address p,
        address i,
        uint256 n
    ) external {
        k = h;
        t = p;
        m = i;
        r = n;

        c = true;

        emit Initialized(h, p, i);
    }

    function d(uint256 l, uint256 j) external {
        require(c, "Not initialized");

        IERC20(t).f(msg.sender, address(this), l);
        IERC20(m).f(msg.sender, address(this), j);

        g += l;
        e += j;
    }

    function ab(
        address u,
        address w,
        uint256 o
    ) external returns (uint256 v) {
        require(c, "Not initialized");
        require(
            (u == t && w == m) ||
                (u == m && w == t),
            "Invalid token pair"
        );

        IERC20(u).f(msg.sender, address(this), o);

        if (u == t) {
            v = (e * o) / (g + o);
            g += o;
            e -= v;
        } else {
            v = (g * o) / (e + o);
            e += o;
            g -= v;
        }

        uint256 ae = (v * r) / 10000;
        v -= ae;

        IERC20(w).transfer(msg.sender, v);
        IERC20(w).transfer(k, ae);

        return v;
    }

    function q() external {
        require(msg.sender == k, "Only maintainer");

        uint256 b = IERC20(t).s(address(this));
        uint256 a = IERC20(m).s(address(this));

        if (b > g) {
            uint256 y = b - g;
            IERC20(t).transfer(k, y);
        }

        if (a > e) {
            uint256 y = a - e;
            IERC20(m).transfer(k, y);
        }
    }
}
