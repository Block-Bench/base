// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xf5b9e7, uint256 _0x25b670) external returns (bool);

    function _0xcea1d8(
        address from,
        address _0xf5b9e7,
        uint256 _0x25b670
    ) external returns (bool);

    function _0x2cd988(address _0x661532) external view returns (uint256);

    function _0x0912b0(address _0x3e087b, uint256 _0x25b670) external returns (bool);
}

interface IAaveOracle {
    function _0x57b274(address _0x2360fc) external view returns (uint256);

    function _0x5a1097(
        address[] calldata _0x0cde15,
        address[] calldata _0xa214e1
    ) external;
}

interface ICurvePool {
    function _0xb8c81e(
        int128 i,
        int128 j,
        uint256 _0x4b1db3,
        uint256 _0x925386
    ) external returns (uint256);

    function _0x775e62(
        int128 i,
        int128 j,
        uint256 _0x4b1db3
    ) external view returns (uint256);

    function _0x20992a(uint256 i) external view returns (uint256);
}

interface ILendingPool {
    function _0x8843e6(
        address _0x2360fc,
        uint256 _0x25b670,
        address _0xe12e14,
        uint16 _0x6abf89
    ) external;

    function _0x2ce3be(
        address _0x2360fc,
        uint256 _0x25b670,
        uint256 _0xe59404,
        uint16 _0x6abf89,
        address _0xe12e14
    ) external;

    function _0xdff017(
        address _0x2360fc,
        uint256 _0x25b670,
        address _0xf5b9e7
    ) external returns (uint256);
}

contract UwuLendingPool is ILendingPool {
    IAaveOracle public _0xc54ce3;
    mapping(address => uint256) public _0x3eaa28;
    mapping(address => uint256) public _0x1df5b8;
    uint256 public constant LTV = 8500;
    uint256 public constant BASIS_POINTS = 10000;

    function _0x8843e6(
        address _0x2360fc,
        uint256 _0x25b670,
        address _0xe12e14,
        uint16 _0x6abf89
    ) external override {
        IERC20(_0x2360fc)._0xcea1d8(msg.sender, address(this), _0x25b670);
        _0x3eaa28[_0xe12e14] += _0x25b670;
    }

    function _0x2ce3be(
        address _0x2360fc,
        uint256 _0x25b670,
        uint256 _0xe59404,
        uint16 _0x6abf89,
        address _0xe12e14
    ) external override {
        uint256 _0x2cd2bd = _0xc54ce3._0x57b274(msg.sender);
        uint256 _0x30771a = _0xc54ce3._0x57b274(_0x2360fc);

        uint256 _0x2cbe78 = (_0x3eaa28[msg.sender] * _0x2cd2bd) /
            1e18;
        uint256 _0xfb2313 = (_0x2cbe78 * LTV) / BASIS_POINTS;

        uint256 _0xd76316 = (_0x25b670 * _0x30771a) / 1e18;

        require(_0xd76316 <= _0xfb2313, "Insufficient collateral");

        _0x1df5b8[msg.sender] += _0x25b670;
        IERC20(_0x2360fc).transfer(_0xe12e14, _0x25b670);
    }

    function _0xdff017(
        address _0x2360fc,
        uint256 _0x25b670,
        address _0xf5b9e7
    ) external override returns (uint256) {
        require(_0x3eaa28[msg.sender] >= _0x25b670, "Insufficient balance");
        _0x3eaa28[msg.sender] -= _0x25b670;
        IERC20(_0x2360fc).transfer(_0xf5b9e7, _0x25b670);
        return _0x25b670;
    }
}

contract CurveOracle {
    ICurvePool public _0x513f51;

    constructor(address _0x123ed9) {
        _0x513f51 = _0x123ed9;
    }

    function _0x57b274(address _0x2360fc) external view returns (uint256) {
        uint256 _0xb73a90 = _0x513f51._0x20992a(0);
        uint256 _0xbae2cc = _0x513f51._0x20992a(1);

        uint256 _0x8154e8 = (_0xbae2cc * 1e18) / _0xb73a90;

        return _0x8154e8;
    }
}
