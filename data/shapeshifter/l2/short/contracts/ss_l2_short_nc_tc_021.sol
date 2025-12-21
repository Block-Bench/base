pragma solidity ^0.8.0;

interface IERC20 {
    function t(address x) external view returns (uint256);

    function transfer(address af, uint256 y) external returns (bool);

    function d(
        address from,
        address af,
        uint256 y
    ) external returns (bool);
}

contract LiquidityPool {
    address public o;
    address public r;
    address public l;

    uint256 public u;
    uint256 public i;
    uint256 public e;

    bool public c;

    event Initialized(address o, address ad, address aa);

    function ab(
        address h,
        address p,
        address g,
        uint256 m
    ) external {
        o = h;
        r = p;
        l = g;
        u = m;

        c = true;

        emit Initialized(h, p, g);
    }

    function f(uint256 k, uint256 j) external {
        require(c, "Not initialized");

        IERC20(r).d(msg.sender, address(this), k);
        IERC20(l).d(msg.sender, address(this), j);

        i += k;
        e += j;
    }

    function ac(
        address s,
        address w,
        uint256 n
    ) external returns (uint256 v) {
        require(c, "Not initialized");
        require(
            (s == r && w == l) ||
                (s == l && w == r),
            "Invalid token pair"
        );

        IERC20(s).d(msg.sender, address(this), n);

        if (s == r) {
            v = (e * n) / (i + n);
            i += n;
            e -= v;
        } else {
            v = (i * n) / (e + n);
            e += n;
            i -= v;
        }

        uint256 ae = (v * u) / 10000;
        v -= ae;

        IERC20(w).transfer(msg.sender, v);
        IERC20(w).transfer(o, ae);

        return v;
    }

    function q() external {
        require(msg.sender == o, "Only maintainer");

        uint256 b = IERC20(r).t(address(this));
        uint256 a = IERC20(l).t(address(this));

        if (b > i) {
            uint256 z = b - i;
            IERC20(r).transfer(o, z);
        }

        if (a > e) {
            uint256 z = a - e;
            IERC20(l).transfer(o, z);
        }
    }
}