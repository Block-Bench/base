pragma solidity ^0.8.0;

interface IERC20 {
    function o(address r) external view returns (uint256);

    function transfer(address ab, uint256 t) external returns (bool);

    function h(
        address from,
        address ab,
        uint256 t
    ) external returns (bool);
}

interface ICErc20 {
    function u(uint256 t) external returns (uint256);

    function a(address r) external returns (uint256);
}

contract LeveragedVault {
    struct Position {
        address w;
        uint256 j;
        uint256 m;
    }

    mapping(uint256 => Position) public n;
    uint256 public d;

    address public v;
    uint256 public l;
    uint256 public e;

    constructor(address s) {
        v = s;
        d = 1;
    }

    function g(
        uint256 b,
        uint256 i
    ) external returns (uint256 k) {
        k = d++;

        n[k] = Position({
            w: msg.sender,
            j: b,
            m: 0
        });

        q(k, i);

        return k;
    }

    function q(uint256 k, uint256 t) internal {
        Position storage aa = n[k];

        uint256 y;

        if (e == 0) {
            y = t;
        } else {
            y = (t * e) / l;
        }

        aa.m += y;
        e += y;
        l += t;

        ICErc20(v).u(t);
    }

    function x(uint256 k, uint256 t) external {
        Position storage aa = n[k];
        require(msg.sender == aa.w, "Not position owner");

        uint256 f = (t * e) / l;

        require(aa.m >= f, "Excessive repayment");

        aa.m -= f;
        e -= f;
        l -= t;
    }

    function c(
        uint256 k
    ) external view returns (uint256) {
        Position storage aa = n[k];

        if (e == 0) return 0;

        return (aa.m * l) / e;
    }

    function p(uint256 k) external {
        Position storage aa = n[k];

        uint256 z = (aa.m * l) / e;

        require(aa.j * 100 < z * 150, "Position is healthy");

        aa.j = 0;
        aa.m = 0;
    }
}