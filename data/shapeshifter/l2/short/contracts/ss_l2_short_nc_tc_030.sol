pragma solidity ^0.8.0;

contract LiquidityPool {
    uint256 public h;
    uint256 public e;
    uint256 public g;

    mapping(address => uint256) public m;

    function c(uint256 k, uint256 i) external returns (uint256 b) {

        if (g == 0) {
            b = k;
        } else {
            uint256 l = (k * g) / h;
            uint256 f = (i * g) / e;

            b = (l + f) / 2;
        }

        m[msg.sender] += b;
        g += b;

        h += k;
        e += i;

        return b;
    }

    function a(uint256 b) external returns (uint256, uint256) {
        uint256 j = (b * h) / g;
        uint256 d = (b * e) / g;

        m[msg.sender] -= b;
        g -= b;

        h -= j;
        e -= d;

        return (j, d);
    }
}