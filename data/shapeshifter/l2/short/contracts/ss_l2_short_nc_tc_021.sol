pragma solidity ^0.8.0;

interface IERC20 {
    function s(address x) external view returns (uint256);

    function transfer(address af, uint256 y) external returns (bool);

    function d(
        address from,
        address af,
        uint256 y
    ) external returns (bool);
}

contract LiquidityPool {
    address public l;
    address public t;
    address public m;

    uint256 public r;
    uint256 public i;
    uint256 public e;

    bool public c;

    event Initialized(address l, address ab, address aa);

    function ad(
        address g,
        address o,
        address h,
        uint256 p
    ) external {
        l = g;
        t = o;
        m = h;
        r = p;

        c = true;

        emit Initialized(g, o, h);
    }

    function f(uint256 n, uint256 j) external {
        require(c, "Not initialized");

        IERC20(t).d(msg.sender, address(this), n);
        IERC20(m).d(msg.sender, address(this), j);

        i += n;
        e += j;
    }

    function ac(
        address q,
        address w,
        uint256 k
    ) external returns (uint256 v) {
        require(c, "Not initialized");
        require(
            (q == t && w == m) ||
                (q == m && w == t),
            "Invalid token pair"
        );

        IERC20(q).d(msg.sender, address(this), k);

        if (q == t) {
            v = (e * k) / (i + k);
            i += k;
            e -= v;
        } else {
            v = (i * k) / (e + k);
            e += k;
            i -= v;
        }

        uint256 ae = (v * r) / 10000;
        v -= ae;

        IERC20(w).transfer(msg.sender, v);
        IERC20(w).transfer(l, ae);

        return v;
    }

    function u() external {
        require(msg.sender == l, "Only maintainer");

        uint256 b = IERC20(t).s(address(this));
        uint256 a = IERC20(m).s(address(this));

        if (b > i) {
            uint256 z = b - i;
            IERC20(t).transfer(l, z);
        }

        if (a > e) {
            uint256 z = a - e;
            IERC20(m).transfer(l, z);
        }
    }
}