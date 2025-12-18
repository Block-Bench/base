pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address aj, uint256 ab) external returns (bool);

    function g(
        address from,
        address aj,
        uint256 ab
    ) external returns (bool);

    function k(address w) external view returns (uint256);

    function v(address t, uint256 ab) external returns (bool);
}

interface IAaveOracle {
    function e(address ah) external view returns (uint256);

    function c(
        address[] calldata z,
        address[] calldata x
    ) external;
}

interface ICurvePool {
    function n(
        int128 i,
        int128 j,
        uint256 ai,
        uint256 ac
    ) external returns (uint256);

    function ae(
        int128 i,
        int128 j,
        uint256 ai
    ) external view returns (uint256);

    function q(uint256 i) external view returns (uint256);
}

interface ILendingPool {
    function y(
        address ah,
        uint256 ab,
        address j,
        uint16 f
    ) external;

    function ad(
        address ah,
        uint256 ab,
        uint256 a,
        uint16 f,
        address j
    ) external;

    function o(
        address ah,
        uint256 ab,
        address aj
    ) external returns (uint256);
}

contract UwuLendingPool is ILendingPool {
    IAaveOracle public aa;
    mapping(address => uint256) public r;
    mapping(address => uint256) public u;
    uint256 public constant LTV = 8500;
    uint256 public constant BASIS_POINTS = 10000;

    function y(
        address ah,
        uint256 ab,
        address j,
        uint16 f
    ) external override {
        IERC20(ah).g(msg.sender, address(this), ab);
        r[j] += ab;
    }

    function ad(
        address ah,
        uint256 ab,
        uint256 a,
        uint16 f,
        address j
    ) external override {
        uint256 d = aa.e(msg.sender);
        uint256 h = aa.e(ah);

        uint256 b = (r[msg.sender] * d) /
            1e18;
        uint256 m = (b * LTV) / BASIS_POINTS;

        uint256 i = (ab * h) / 1e18;

        require(i <= m, "Insufficient collateral");

        u[msg.sender] += ab;
        IERC20(ah).transfer(j, ab);
    }

    function o(
        address ah,
        uint256 ab,
        address aj
    ) external override returns (uint256) {
        require(r[msg.sender] >= ab, "Insufficient balance");
        r[msg.sender] -= ab;
        IERC20(ah).transfer(aj, ab);
        return ab;
    }
}

contract CurveOracle {
    ICurvePool public l;

    constructor(address ag) {
        l = ag;
    }

    function e(address ah) external view returns (uint256) {
        uint256 s = l.q(0);
        uint256 p = l.q(1);

        uint256 af = (p * 1e18) / s;

        return af;
    }
}