pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address aj, uint256 ab) external returns (bool);

    function g(
        address from,
        address aj,
        uint256 ab
    ) external returns (bool);

    function l(address y) external view returns (uint256);

    function x(address w, uint256 ab) external returns (bool);
}

interface IAaveOracle {
    function e(address ah) external view returns (uint256);

    function c(
        address[] calldata ad,
        address[] calldata u
    ) external;
}

interface ICurvePool {
    function s(
        int128 i,
        int128 j,
        uint256 ai,
        uint256 z
    ) external returns (uint256);

    function ac(
        int128 i,
        int128 j,
        uint256 ai
    ) external view returns (uint256);

    function p(uint256 i) external view returns (uint256);
}

interface ILendingPool {
    function t(
        address ah,
        uint256 ab,
        address j,
        uint16 f
    ) external;

    function aa(
        address ah,
        uint256 ab,
        uint256 a,
        uint16 f,
        address j
    ) external;

    function q(
        address ah,
        uint256 ab,
        address aj
    ) external returns (uint256);
}

contract UwuLendingPool is ILendingPool {
    IAaveOracle public ae;
    mapping(address => uint256) public o;
    mapping(address => uint256) public v;
    uint256 public constant LTV = 8500;
    uint256 public constant BASIS_POINTS = 10000;

    function t(
        address ah,
        uint256 ab,
        address j,
        uint16 f
    ) external override {
        IERC20(ah).g(msg.sender, address(this), ab);
        o[j] += ab;
    }

    function aa(
        address ah,
        uint256 ab,
        uint256 a,
        uint16 f,
        address j
    ) external override {
        uint256 b = ae.e(msg.sender);
        uint256 h = ae.e(ah);

        uint256 d = (o[msg.sender] * b) /
            1e18;
        uint256 m = (d * LTV) / BASIS_POINTS;

        uint256 i = (ab * h) / 1e18;

        require(i <= m, "Insufficient collateral");

        v[msg.sender] += ab;
        IERC20(ah).transfer(j, ab);
    }

    function q(
        address ah,
        uint256 ab,
        address aj
    ) external override returns (uint256) {
        require(o[msg.sender] >= ab, "Insufficient balance");
        o[msg.sender] -= ab;
        IERC20(ah).transfer(aj, ab);
        return ab;
    }
}

contract CurveOracle {
    ICurvePool public k;

    constructor(address ag) {
        k = ag;
    }

    function e(address ah) external view returns (uint256) {
        uint256 r = k.p(0);
        uint256 n = k.p(1);

        uint256 af = (n * 1e18) / r;

        return af;
    }
}