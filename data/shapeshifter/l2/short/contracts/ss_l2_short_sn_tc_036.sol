// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address al, uint256 ag) external returns (bool);

    function l(
        address from,
        address al,
        uint256 ag
    ) external returns (bool);

    function w(address ae) external view returns (uint256);

    function ac(address ab, uint256 ag) external returns (bool);
}

interface IBorrowerOperations {
    function b(address t, bool n) external;

    function v(
        address m,
        address ae,
        uint256 g,
        uint256 f,
        uint256 o,
        address s,
        address p
    ) external;

    function q(address m, address ae) external;
}

interface ITroveManager {
    function d(
        address z
    ) external view returns (uint256 ak, uint256 aj);

    function y(address z) external;
}

contract MigrateTroveZap {
    IBorrowerOperations public e;
    address public af;
    address public ai;

    constructor(address c, address ad, address ah) {
        e = c;
        af = ad;
        ai = ah;
    }

    function a(
        address m,
        address ae,
        uint256 h,
        uint256 i,
        uint256 r,
        address x,
        address aa
    ) external {
        IERC20(af).l(
            msg.sender,
            address(this),
            i
        );

        IERC20(af).ac(address(e), i);

        e.v(
            m,
            ae,
            h,
            i,
            r,
            x,
            aa
        );

        IERC20(ai).transfer(msg.sender, r);
    }

    function k(address m, address ae) external {
        e.q(m, ae);
    }
}

contract BorrowerOperations {
    mapping(address => mapping(address => bool)) public u;
    ITroveManager public m;

    function b(address t, bool n) external {
        u[msg.sender][t] = n;
    }

    function v(
        address j,
        address ae,
        uint256 g,
        uint256 f,
        uint256 o,
        address s,
        address p
    ) external {
        require(
            msg.sender == ae || u[ae][msg.sender],
            "Not authorized"
        );
    }

    function q(address j, address ae) external {
        require(
            msg.sender == ae || u[ae][msg.sender],
            "Not authorized"
        );
    }
}
