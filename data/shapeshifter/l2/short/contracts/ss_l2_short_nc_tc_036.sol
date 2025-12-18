pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address al, uint256 ag) external returns (bool);

    function l(
        address from,
        address al,
        uint256 ag
    ) external returns (bool);

    function x(address ae) external view returns (uint256);

    function ad(address ab, uint256 ag) external returns (bool);
}

interface IBorrowerOperations {
    function a(address v, bool o) external;

    function t(
        address m,
        address ae,
        uint256 f,
        uint256 g,
        uint256 n,
        address q,
        address s
    ) external;

    function r(address m, address ae) external;
}

interface ITroveManager {
    function d(
        address aa
    ) external view returns (uint256 ak, uint256 aj);

    function y(address aa) external;
}

contract MigrateTroveZap {
    IBorrowerOperations public e;
    address public af;
    address public ai;

    constructor(address c, address ac, address ah) {
        e = c;
        af = ac;
        ai = ah;
    }

    function b(
        address m,
        address ae,
        uint256 i,
        uint256 h,
        uint256 p,
        address u,
        address z
    ) external {
        IERC20(af).l(
            msg.sender,
            address(this),
            h
        );

        IERC20(af).ad(address(e), h);

        e.t(
            m,
            ae,
            i,
            h,
            p,
            u,
            z
        );

        IERC20(ai).transfer(msg.sender, p);
    }

    function k(address m, address ae) external {
        e.r(m, ae);
    }
}

contract BorrowerOperations {
    mapping(address => mapping(address => bool)) public w;
    ITroveManager public m;

    function a(address v, bool o) external {
        w[msg.sender][v] = o;
    }

    function t(
        address j,
        address ae,
        uint256 f,
        uint256 g,
        uint256 n,
        address q,
        address s
    ) external {
        require(
            msg.sender == ae || w[ae][msg.sender],
            "Not authorized"
        );
    }

    function r(address j, address ae) external {
        require(
            msg.sender == ae || w[ae][msg.sender],
            "Not authorized"
        );
    }
}