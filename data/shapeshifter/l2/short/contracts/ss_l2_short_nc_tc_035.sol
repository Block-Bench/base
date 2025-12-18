pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address ah, uint256 ad) external returns (bool);

    function o(
        address from,
        address ah,
        uint256 ad
    ) external returns (bool);

    function v(address aa) external view returns (uint256);

    function z(address w, uint256 ad) external returns (bool);
}

interface IERC721 {
    function o(address from, address ah, uint256 y) external;

    function x(uint256 y) external view returns (address);
}

contract WiseLending {
    struct PoolData {
        uint256 l;
        uint256 e;
        uint256 g;
        uint256 i;
    }

    mapping(address => PoolData) public k;
    mapping(uint256 => mapping(address => uint256)) public f;
    mapping(uint256 => mapping(address => uint256)) public h;

    IERC721 public q;
    uint256 public r;

    function n() external returns (uint256) {
        uint256 af = ++r;
        return af;
    }

    function d(
        uint256 ae,
        address u,
        uint256 ac
    ) external returns (uint256 s) {
        IERC20(u).o(msg.sender, address(this), ac);

        PoolData storage ag = k[u];

        if (ag.e == 0) {
            s = ac;
            ag.e = ac;
        } else {
            s =
                (ac * ag.e) /
                ag.l;
            ag.e += s;
        }

        ag.l += ac;
        f[ae][u] += s;

        return s;
    }

    function c(
        uint256 ae,
        address u,
        uint256 ab
    ) external returns (uint256 m) {
        require(
            f[ae][u] >= ab,
            "Insufficient shares"
        );

        PoolData storage ag = k[u];

        m =
            (ab * ag.l) /
            ag.e;

        f[ae][u] -= ab;
        ag.e -= ab;
        ag.l -= m;

        IERC20(u).transfer(msg.sender, m);

        return m;
    }

    function b(
        uint256 ae,
        address u,
        uint256 j
    ) external returns (uint256 t) {
        PoolData storage ag = k[u];

        t =
            (j * ag.e) /
            ag.l;

        require(
            f[ae][u] >= t,
            "Insufficient shares"
        );

        f[ae][u] -= t;
        ag.e -= t;
        ag.l -= j;

        IERC20(u).transfer(msg.sender, j);

        return t;
    }

    function a(
        uint256 ae,
        address u
    ) external view returns (uint256) {
        return f[ae][u];
    }

    function p(address u) external view returns (uint256) {
        return k[u].l;
    }
}