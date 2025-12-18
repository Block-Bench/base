// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function m(address s) external view returns (uint256);

    function transfer(address ab, uint256 t) external returns (bool);

    function g(
        address from,
        address ab,
        uint256 t
    ) external returns (bool);
}

interface ICErc20 {
    function u(uint256 t) external returns (uint256);

    function a(address s) external returns (uint256);
}

contract LeveragedVault {
    struct Position {
        address y;
        uint256 j;
        uint256 p;
    }

    mapping(uint256 => Position) public l;
    uint256 public d;

    address public v;
    uint256 public o;
    uint256 public e;

    constructor(address q) {
        v = q;
        d = 1;
    }

    function h(
        uint256 b,
        uint256 i
    ) external returns (uint256 k) {
        k = d++;

        l[k] = Position({
            y: msg.sender,
            j: b,
            p: 0
        });

        r(k, i);

        return k;
    }

    function r(uint256 k, uint256 t) internal {
        Position storage aa = l[k];

        uint256 x;

        if (e == 0) {
            x = t;
        } else {
            x = (t * e) / o;
        }

        aa.p += x;
        e += x;
        o += t;

        ICErc20(v).u(t);
    }

    function w(uint256 k, uint256 t) external {
        Position storage aa = l[k];
        require(msg.sender == aa.y, "Not position owner");

        uint256 f = (t * e) / o;

        require(aa.p >= f, "Excessive repayment");

        aa.p -= f;
        e -= f;
        o -= t;
    }

    function c(
        uint256 k
    ) external view returns (uint256) {
        Position storage aa = l[k];

        if (e == 0) return 0;

        return (aa.p * o) / e;
    }

    function n(uint256 k) external {
        Position storage aa = l[k];

        uint256 z = (aa.p * o) / e;

        require(aa.j * 100 < z * 150, "Position is healthy");

        aa.j = 0;
        aa.p = 0;
    }
}
