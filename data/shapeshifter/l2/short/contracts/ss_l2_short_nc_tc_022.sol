pragma solidity ^0.8.0;

interface IERC20 {
    function j(address r) external view returns (uint256);

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

    uint112 private o;
    uint112 private m;

    uint256 public constant TOTAL_FEE = 16;

    constructor(address u, address t) {
        x = u;
        w = t;
    }

    function aa(address ab) external returns (uint256 i) {
        uint256 p = IERC20(x).j(address(this));
        uint256 n = IERC20(w).j(address(this));

        uint256 s = p - o;
        uint256 q = n - m;

        i = z(s * q);

        o = uint112(p);
        m = uint112(n);

        return i;
    }

    function y(
        uint256 e,
        uint256 f,
        address ab,
        bytes calldata data
    ) external {
        require(e > 0 || f > 0, "INSUFFICIENT_OUTPUT_AMOUNT");

        uint112 l = o;
        uint112 h = m;

        require(
            e < l && f < h,
            "INSUFFICIENT_LIQUIDITY"
        );

        if (e > 0) IERC20(x).transfer(ab, e);
        if (f > 0) IERC20(w).transfer(ab, f);

        uint256 p = IERC20(x).j(address(this));
        uint256 n = IERC20(w).j(address(this));

        uint256 g = p > l - e
            ? p - (l - e)
            : 0;
        uint256 k = n > h - f
            ? n - (h - f)
            : 0;

        require(g > 0 || k > 0, "INSUFFICIENT_INPUT_AMOUNT");

        uint256 b = p * 10000 - g * TOTAL_FEE;
        uint256 a = n * 10000 - k * TOTAL_FEE;

        require(
            b * a >=
                uint256(l) * h * (1000 ** 2),
            "K"
        );

        o = uint112(p);
        m = uint112(n);
    }

    function d() external view returns (uint112, uint112, uint32) {
        return (o, m, 0);
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