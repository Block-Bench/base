// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function g(address u) external view returns (uint256);

    function transfer(address ab, uint256 v) external returns (bool);

    function c(
        address from,
        address ab,
        uint256 v
    ) external returns (bool);
}

contract TokenPair {
    address public x;
    address public w;

    uint112 private p;
    uint112 private m;

    uint256 public constant TOTAL_FEE = 16;

    constructor(address r, address q) {
        x = r;
        w = q;
    }

    function aa(address ab) external returns (uint256 k) {
        uint256 n = IERC20(x).g(address(this));
        uint256 o = IERC20(w).g(address(this));

        uint256 s = n - p;
        uint256 t = o - m;

        k = z(s * t);

        p = uint112(n);
        m = uint112(o);

        return k;
    }

    function y(
        uint256 f,
        uint256 e,
        address ab,
        bytes calldata data
    ) external {
        require(f > 0 || e > 0, "INSUFFICIENT_OUTPUT_AMOUNT");

        uint112 j = p;
        uint112 l = m;

        require(
            f < j && e < l,
            "INSUFFICIENT_LIQUIDITY"
        );

        if (f > 0) IERC20(x).transfer(ab, f);
        if (e > 0) IERC20(w).transfer(ab, e);

        uint256 n = IERC20(x).g(address(this));
        uint256 o = IERC20(w).g(address(this));

        uint256 h = n > j - f
            ? n - (j - f)
            : 0;
        uint256 i = o > l - e
            ? o - (l - e)
            : 0;

        require(h > 0 || i > 0, "INSUFFICIENT_INPUT_AMOUNT");

        uint256 a = n * 10000 - h * TOTAL_FEE;
        uint256 b = o * 10000 - i * TOTAL_FEE;

        require(
            a * b >=
                uint256(j) * l * (1000 ** 2),
            "K"
        );

        p = uint112(n);
        m = uint112(o);
    }

    function d() external view returns (uint112, uint112, uint32) {
        return (p, m, 0);
    }

    function z(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
