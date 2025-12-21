// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function f(address k) external view returns (uint256);
    function transfer(address s, uint256 l) external returns (bool);
    function a(address from, address s, uint256 l) external returns (bool);
}

interface IPriceOracle {
    function h(address q) external view returns (uint256);
}

contract VaultStrategy {
    address public e;
    address public m;
    uint256 public d;

    mapping(address => uint256) public n;

    constructor(address o, address j) {
        e = o;
        m = j;
    }

    function i(uint256 l) external returns (uint256 c) {
        uint256 r = IERC20(e).f(address(this));

        if (d == 0) {
            c = l;
        } else {
            uint256 p = IPriceOracle(m).h(e);
            c = (l * d * 1e18) / (r * p);
        }

        n[msg.sender] += c;
        d += c;

        IERC20(e).a(msg.sender, address(this), l);
        return c;
    }

    function g(uint256 b) external {
        uint256 r = IERC20(e).f(address(this));

        uint256 p = IPriceOracle(m).h(e);
        uint256 l = (b * r * p) / (d * 1e18);

        n[msg.sender] -= b;
        d -= b;

        IERC20(e).transfer(msg.sender, l);
    }
}
