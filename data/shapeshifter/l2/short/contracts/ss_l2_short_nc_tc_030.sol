pragma solidity ^0.8.0;

contract LiquidityPool {
    uint256 public i;
    uint256 public e;
    uint256 public j;

    mapping(address => uint256) public m;

    function c(uint256 l, uint256 g) external returns (uint256 b) {

        if (j == 0) {
            b = l;
        } else {
            uint256 k = (l * j) / i;
            uint256 f = (g * j) / e;

            b = (k + f) / 2;
        }

        m[msg.sender] += b;
        j += b;

        i += l;
        e += g;

        return b;
    }

    function a(uint256 b) external returns (uint256, uint256) {
        uint256 h = (b * i) / j;
        uint256 d = (b * e) / j;

        m[msg.sender] -= b;
        j -= b;

        i -= h;
        e -= d;

        return (h, d);
    }
}