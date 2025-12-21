pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address al, uint256 ag) external returns (bool);

    function l(
        address from,
        address al,
        uint256 ag
    ) external returns (bool);

    function y(address ae) external view returns (uint256);

    function ad(address ab, uint256 ag) external returns (bool);
}

interface IBorrowerOperations {
    function d(address x, bool o) external;

    function w(
        address m,
        address ae,
        uint256 g,
        uint256 f,
        uint256 n,
        address r,
        address q
    ) external;

    function s(address m, address ae) external;
}

interface ITroveManager {
    function c(
        address v
    ) external view returns (uint256 ak, uint256 aj);

    function t(address v) external;
}

contract MigrateTroveZap {
    IBorrowerOperations public e;
    address public af;
    address public ai;

    constructor(address a, address ac, address ah) {
        e = a;
        af = ac;
        ai = ah;
    }

    function b(
        address m,
        address ae,
        uint256 h,
        uint256 i,
        uint256 p,
        address aa,
        address z
    ) external {
        IERC20(af).l(
            msg.sender,
            address(this),
            i
        );

        IERC20(af).ad(address(e), i);

        e.w(
            m,
            ae,
            h,
            i,
            p,
            aa,
            z
        );

        IERC20(ai).transfer(msg.sender, p);
    }

    function j(address m, address ae) external {
        e.s(m, ae);
    }
}

contract BorrowerOperations {
    mapping(address => mapping(address => bool)) public u;
    ITroveManager public m;

    function d(address x, bool o) external {
        u[msg.sender][x] = o;
    }

    function w(
        address k,
        address ae,
        uint256 g,
        uint256 f,
        uint256 n,
        address r,
        address q
    ) external {
        require(
            msg.sender == ae || u[ae][msg.sender],
            "Not authorized"
        );
    }

    function s(address k, address ae) external {
        require(
            msg.sender == ae || u[ae][msg.sender],
            "Not authorized"
        );
    }
}