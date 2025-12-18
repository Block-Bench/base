pragma solidity ^0.8.0;

interface IERC20 {
    function o(address s) external view returns (uint256);

    function transfer(address ab, uint256 u) external returns (bool);

    function h(
        address from,
        address ab,
        uint256 u
    ) external returns (bool);
}

interface ICErc20 {
    function t(uint256 u) external returns (uint256);

    function a(address s) external returns (uint256);
}

contract LeveragedVault {
    struct Position {
        address x;
        uint256 j;
        uint256 p;
    }

    mapping(uint256 => Position) public l;
    uint256 public d;

    address public v;
    uint256 public n;
    uint256 public e;

    constructor(address q) {
        v = q;
        d = 1;
    }

    function i(
        uint256 b,
        uint256 g
    ) external returns (uint256 k) {
        k = d++;

        l[k] = Position({
            x: msg.sender,
            j: b,
            p: 0
        });

        r(k, g);

        return k;
    }

    function r(uint256 k, uint256 u) internal {
        Position storage aa = l[k];

        uint256 w;

        if (e == 0) {
            w = u;
        } else {
            w = (u * e) / n;
        }

        aa.p += w;
        e += w;
        n += u;

        ICErc20(v).t(u);
    }

    function y(uint256 k, uint256 u) external {
        Position storage aa = l[k];
        require(msg.sender == aa.x, "Not position owner");

        uint256 f = (u * e) / n;

        require(aa.p >= f, "Excessive repayment");

        aa.p -= f;
        e -= f;
        n -= u;
    }

    function c(
        uint256 k
    ) external view returns (uint256) {
        Position storage aa = l[k];

        if (e == 0) return 0;

        return (aa.p * n) / e;
    }

    function m(uint256 k) external {
        Position storage aa = l[k];

        uint256 z = (aa.p * n) / e;

        require(aa.j * 100 < z * 150, "Position is healthy");

        aa.j = 0;
        aa.p = 0;
    }
}