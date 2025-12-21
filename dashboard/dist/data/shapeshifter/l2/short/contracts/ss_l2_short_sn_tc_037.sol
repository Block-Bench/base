// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address ai, uint256 ac) external returns (bool);

    function g(
        address from,
        address ai,
        uint256 ac
    ) external returns (bool);

    function k(address y) external view returns (uint256);

    function w(address t, uint256 ac) external returns (bool);
}

interface IAaveOracle {
    function e(address af) external view returns (uint256);

    function c(
        address[] calldata ab,
        address[] calldata x
    ) external;
}

interface ICurvePool {
    function p(
        int128 i,
        int128 j,
        uint256 aj,
        uint256 aa
    ) external returns (uint256);

    function z(
        int128 i,
        int128 j,
        uint256 aj
    ) external view returns (uint256);

    function o(uint256 i) external view returns (uint256);
}

interface ILendingPool {
    function v(
        address af,
        uint256 ac,
        address j,
        uint16 f
    ) external;

    function ad(
        address af,
        uint256 ac,
        uint256 a,
        uint16 f,
        address j
    ) external;

    function s(
        address af,
        uint256 ac,
        address ai
    ) external returns (uint256);
}

contract UwuLendingPool is ILendingPool {
    IAaveOracle public ae;
    mapping(address => uint256) public n;
    mapping(address => uint256) public u;
    uint256 public constant LTV = 8500;
    uint256 public constant BASIS_POINTS = 10000;

    function v(
        address af,
        uint256 ac,
        address j,
        uint16 f
    ) external override {
        IERC20(af).g(msg.sender, address(this), ac);
        n[j] += ac;
    }

    function ad(
        address af,
        uint256 ac,
        uint256 a,
        uint16 f,
        address j
    ) external override {
        uint256 b = ae.e(msg.sender);
        uint256 i = ae.e(af);

        uint256 d = (n[msg.sender] * b) /
            1e18;
        uint256 l = (d * LTV) / BASIS_POINTS;

        uint256 h = (ac * i) / 1e18;

        require(h <= l, "Insufficient collateral");

        u[msg.sender] += ac;
        IERC20(af).transfer(j, ac);
    }

    function s(
        address af,
        uint256 ac,
        address ai
    ) external override returns (uint256) {
        require(n[msg.sender] >= ac, "Insufficient balance");
        n[msg.sender] -= ac;
        IERC20(af).transfer(ai, ac);
        return ac;
    }
}

contract CurveOracle {
    ICurvePool public m;

    constructor(address ag) {
        m = ag;
    }

    function e(address af) external view returns (uint256) {
        uint256 q = m.o(0);
        uint256 r = m.o(1);

        uint256 ah = (r * 1e18) / q;

        return ah;
    }
}
