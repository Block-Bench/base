// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x12e31c, uint256 _0xacbbad) external returns (bool);

    function _0x326756(
        address from,
        address _0x12e31c,
        uint256 _0xacbbad
    ) external returns (bool);

    function _0x175e73(address _0x6f8713) external view returns (uint256);

    function _0x9432ab(address _0x7172e1, uint256 _0xacbbad) external returns (bool);
}

interface IAaveOracle {
    function _0x5edcb7(address _0x74628a) external view returns (uint256);

    function _0x4770a4(
        address[] calldata _0x61fc12,
        address[] calldata _0x4b5432
    ) external;
}

interface ICurvePool {
    function _0x80f2c2(
        int128 i,
        int128 j,
        uint256 _0xe9468e,
        uint256 _0x9fd863
    ) external returns (uint256);

    function _0x88162a(
        int128 i,
        int128 j,
        uint256 _0xe9468e
    ) external view returns (uint256);

    function _0x78bd13(uint256 i) external view returns (uint256);
}

interface ILendingPool {
    function _0x772135(
        address _0x74628a,
        uint256 _0xacbbad,
        address _0xd1aa8e,
        uint16 _0x8915ae
    ) external;

    function _0x53ca02(
        address _0x74628a,
        uint256 _0xacbbad,
        uint256 _0x90de7c,
        uint16 _0x8915ae,
        address _0xd1aa8e
    ) external;

    function _0xe3f89c(
        address _0x74628a,
        uint256 _0xacbbad,
        address _0x12e31c
    ) external returns (uint256);
}

contract UwuLendingPool is ILendingPool {
    IAaveOracle public _0x4db192;
    mapping(address => uint256) public _0x491cfe;
    mapping(address => uint256) public _0x6785a1;
    uint256 public constant LTV = 8500;
    uint256 public constant BASIS_POINTS = 10000;

    function _0x772135(
        address _0x74628a,
        uint256 _0xacbbad,
        address _0xd1aa8e,
        uint16 _0x8915ae
    ) external override {
        IERC20(_0x74628a)._0x326756(msg.sender, address(this), _0xacbbad);
        _0x491cfe[_0xd1aa8e] += _0xacbbad;
    }

    function _0x53ca02(
        address _0x74628a,
        uint256 _0xacbbad,
        uint256 _0x90de7c,
        uint16 _0x8915ae,
        address _0xd1aa8e
    ) external override {
        uint256 _0x9b01ad = _0x4db192._0x5edcb7(msg.sender);
        uint256 _0xbaadd9 = _0x4db192._0x5edcb7(_0x74628a);

        uint256 _0x9e9555 = (_0x491cfe[msg.sender] * _0x9b01ad) /
            1e18;
        uint256 _0x007590 = (_0x9e9555 * LTV) / BASIS_POINTS;

        uint256 _0xe937c5 = (_0xacbbad * _0xbaadd9) / 1e18;

        require(_0xe937c5 <= _0x007590, "Insufficient collateral");

        _0x6785a1[msg.sender] += _0xacbbad;
        IERC20(_0x74628a).transfer(_0xd1aa8e, _0xacbbad);
    }

    function _0xe3f89c(
        address _0x74628a,
        uint256 _0xacbbad,
        address _0x12e31c
    ) external override returns (uint256) {
        require(_0x491cfe[msg.sender] >= _0xacbbad, "Insufficient balance");
        _0x491cfe[msg.sender] -= _0xacbbad;
        IERC20(_0x74628a).transfer(_0x12e31c, _0xacbbad);
        return _0xacbbad;
    }
}

contract CurveOracle {
    ICurvePool public _0x7fed22;

    constructor(address _0x9e3edb) {
        _0x7fed22 = _0x9e3edb;
    }

    function _0x5edcb7(address _0x74628a) external view returns (uint256) {
        uint256 _0x442641 = _0x7fed22._0x78bd13(0);
        uint256 _0xb7ea31 = _0x7fed22._0x78bd13(1);

        uint256 _0xb9d877 = (_0xb7ea31 * 1e18) / _0x442641;

        return _0xb9d877;
    }
}
