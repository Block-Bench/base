pragma solidity ^0.8.0;

interface IERC20 {
    function k(address u) external view returns (uint256);

    function transfer(address ab, uint256 v) external returns (bool);

    function c(
        address from,
        address ab,
        uint256 v
    ) external returns (bool);
}

contract TokenPair {
    address public w;
    address public x;

    uint112 private p;
    uint112 private n;

    uint256 public constant TOTAL_FEE = 16;

    constructor(address q, address s) {
        w = q;
        x = s;
    }

    function aa(address ab) external returns (uint256 i) {
        uint256 o = IERC20(w).k(address(this));
        uint256 m = IERC20(x).k(address(this));

        uint256 r = o - p;
        uint256 t = m - n;

        i = z(r * t);

        p = uint112(o);
        n = uint112(m);

        return i;
    }

    function y(
        uint256 e,
        uint256 f,
        address ab,
        bytes calldata data
    ) external {
        require(e > 0 || f > 0, "INSUFFICIENT_OUTPUT_AMOUNT");

        uint112 l = p;
        uint112 j = n;

        require(
            e < l && f < j,
            "INSUFFICIENT_LIQUIDITY"
        );

        if (e > 0) IERC20(w).transfer(ab, e);
        if (f > 0) IERC20(x).transfer(ab, f);

        uint256 o = IERC20(w).k(address(this));
        uint256 m = IERC20(x).k(address(this));

        uint256 g = o > l - e
            ? o - (l - e)
            : 0;
        uint256 h = m > j - f
            ? m - (j - f)
            : 0;

        require(g > 0 || h > 0, "INSUFFICIENT_INPUT_AMOUNT");

        uint256 a = o * 10000 - g * TOTAL_FEE;
        uint256 b = m * 10000 - h * TOTAL_FEE;

        require(
            a * b >=
                uint256(l) * j * (1000 ** 2),
            "K"
        );

        p = uint112(o);
        n = uint112(m);
    }

    function d() external view returns (uint112, uint112, uint32) {
        return (p, n, 0);
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