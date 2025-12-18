pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address ah, uint256 ad) external returns (bool);

    function o(
        address from,
        address ah,
        uint256 ad
    ) external returns (bool);

    function v(address ac) external view returns (uint256);

    function ab(address y, uint256 ad) external returns (bool);
}

interface IERC721 {
    function o(address from, address ah, uint256 z) external;

    function x(uint256 z) external view returns (address);
}

contract WiseLending {
    struct PoolData {
        uint256 k;
        uint256 d;
        uint256 f;
        uint256 h;
    }

    mapping(address => PoolData) public l;
    mapping(uint256 => mapping(address => uint256)) public g;
    mapping(uint256 => mapping(address => uint256)) public i;

    IERC721 public p;
    uint256 public n;

    function q() external returns (uint256) {
        uint256 af = ++n;
        return af;
    }

    function e(
        uint256 ae,
        address u,
        uint256 aa
    ) external returns (uint256 s) {
        IERC20(u).o(msg.sender, address(this), aa);

        PoolData storage ag = l[u];

        if (ag.d == 0) {
            s = aa;
            ag.d = aa;
        } else {
            s =
                (aa * ag.d) /
                ag.k;
            ag.d += s;
        }

        ag.k += aa;
        g[ae][u] += s;

        return s;
    }

    function c(
        uint256 ae,
        address u,
        uint256 w
    ) external returns (uint256 m) {
        require(
            g[ae][u] >= w,
            "Insufficient shares"
        );

        PoolData storage ag = l[u];

        m =
            (w * ag.k) /
            ag.d;

        g[ae][u] -= w;
        ag.d -= w;
        ag.k -= m;

        IERC20(u).transfer(msg.sender, m);

        return m;
    }

    function b(
        uint256 ae,
        address u,
        uint256 j
    ) external returns (uint256 t) {
        PoolData storage ag = l[u];

        t =
            (j * ag.d) /
            ag.k;

        require(
            g[ae][u] >= t,
            "Insufficient shares"
        );

        g[ae][u] -= t;
        ag.d -= t;
        ag.k -= j;

        IERC20(u).transfer(msg.sender, j);

        return t;
    }

    function a(
        uint256 ae,
        address u
    ) external view returns (uint256) {
        return g[ae][u];
    }

    function r(address u) external view returns (uint256) {
        return l[u].k;
    }
}