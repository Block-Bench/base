// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address ah, uint256 ae) external returns (bool);

    function p(
        address from,
        address ah,
        uint256 ae
    ) external returns (bool);

    function v(address ac) external view returns (uint256);

    function z(address y, uint256 ae) external returns (bool);
}

interface IERC721 {
    function p(address from, address ah, uint256 aa) external;

    function w(uint256 aa) external view returns (address);
}

contract WiseLending {
    struct PoolData {
        uint256 l;
        uint256 d;
        uint256 f;
        uint256 h;
    }

    mapping(address => PoolData) public k;
    mapping(uint256 => mapping(address => uint256)) public g;
    mapping(uint256 => mapping(address => uint256)) public i;

    IERC721 public o;
    uint256 public n;

    function r() external returns (uint256) {
        uint256 af = ++n;
        return af;
    }

    function e(
        uint256 ad,
        address u,
        uint256 x
    ) external returns (uint256 t) {
        IERC20(u).p(msg.sender, address(this), x);

        PoolData storage ag = k[u];

        if (ag.d == 0) {
            t = x;
            ag.d = x;
        } else {
            t =
                (x * ag.d) /
                ag.l;
            ag.d += t;
        }

        ag.l += x;
        g[ad][u] += t;

        return t;
    }

    function b(
        uint256 ad,
        address u,
        uint256 ab
    ) external returns (uint256 m) {
        require(
            g[ad][u] >= ab,
            "Insufficient shares"
        );

        PoolData storage ag = k[u];

        m =
            (ab * ag.l) /
            ag.d;

        g[ad][u] -= ab;
        ag.d -= ab;
        ag.l -= m;

        IERC20(u).transfer(msg.sender, m);

        return m;
    }

    function c(
        uint256 ad,
        address u,
        uint256 j
    ) external returns (uint256 s) {
        PoolData storage ag = k[u];

        s =
            (j * ag.d) /
            ag.l;

        require(
            g[ad][u] >= s,
            "Insufficient shares"
        );

        g[ad][u] -= s;
        ag.d -= s;
        ag.l -= j;

        IERC20(u).transfer(msg.sender, j);

        return s;
    }

    function a(
        uint256 ad,
        address u
    ) external view returns (uint256) {
        return g[ad][u];
    }

    function q(address u) external view returns (uint256) {
        return k[u].l;
    }
}
