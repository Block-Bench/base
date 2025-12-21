// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function i(address t) external view returns (uint256);

    function transfer(address aa, uint256 w) external returns (bool);
}

contract TokenPool {
    struct Token {
        address z;
        uint256 balance;
        uint256 v;
    }

    mapping(address => Token) public u;
    address[] public n;
    uint256 public f;

    constructor() {
        f = 100;
    }

    function p(address x, uint256 c) external {
        u[x] = Token({z: x, balance: 0, v: c});
        n.push(x);
    }

    function y(
        address s,
        address q,
        uint256 o
    ) external returns (uint256 j) {
        require(u[s].z != address(0), "Invalid token");
        require(u[q].z != address(0), "Invalid token");

        IERC20(s).transfer(address(this), o);
        u[s].balance += o;

        j = a(s, q, o);

        require(
            u[q].balance >= j,
            "Insufficient liquidity"
        );
        u[q].balance -= j;
        IERC20(q).transfer(msg.sender, j);

        b();

        return j;
    }

    function a(
        address s,
        address q,
        uint256 o
    ) public view returns (uint256) {
        uint256 r = u[s].v;
        uint256 k = u[q].v;
        uint256 h = u[q].balance;

        uint256 m = h * o * k;
        uint256 e = u[s].balance *
            r +
            o *
            k;

        return m / e;
    }

    function b() internal {
        uint256 g = 0;

        for (uint256 i = 0; i < n.length; i++) {
            address x = n[i];
            g += u[x].balance;
        }

        for (uint256 i = 0; i < n.length; i++) {
            address x = n[i];
            u[x].v = (u[x].balance * 100) / g;
        }
    }

    function l(address x) external view returns (uint256) {
        return u[x].v;
    }

    function d(address x, uint256 w) external {
        require(u[x].z != address(0), "Invalid token");
        IERC20(x).transfer(address(this), w);
        u[x].balance += w;
        b();
    }
}
