// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LiquidityPool {
    uint256 public i;
    uint256 public e;
    uint256 public h;

    mapping(address => uint256) public m;

    function c(uint256 k, uint256 f) external returns (uint256 b) {

        if (h == 0) {
            b = k;
        } else {
            uint256 l = (k * h) / i;
            uint256 j = (f * h) / e;

            b = (l + j) / 2;
        }

        m[msg.sender] += b;
        h += b;

        i += k;
        e += f;

        return b;
    }

    function a(uint256 b) external returns (uint256, uint256) {
        uint256 g = (b * i) / h;
        uint256 d = (b * e) / h;

        m[msg.sender] -= b;
        h -= b;

        i -= g;
        e -= d;

        return (g, d);
    }
}
