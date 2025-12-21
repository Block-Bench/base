// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x490498, uint256 _0xd3f4c5) external returns (bool);

    function _0xee8201(
        address from,
        address _0x490498,
        uint256 _0xd3f4c5
    ) external returns (bool);

    function _0x68931e(address _0x6f497e) external view returns (uint256);

    function _0xc2f45a(address _0x08b956, uint256 _0xd3f4c5) external returns (bool);
}

interface IERC721 {
    function _0xee8201(address from, address _0x490498, uint256 _0x7c3f70) external;

    function _0x1e3ed0(uint256 _0x7c3f70) external view returns (address);
}

contract WiseLending {
    struct PoolData {
        uint256 _0xf1f680;
        uint256 _0x6e00f6;
        uint256 _0xd537b2;
        uint256 _0x596d01;
    }

    mapping(address => PoolData) public _0x8667a9;
    mapping(uint256 => mapping(address => uint256)) public _0x6ac733;
    mapping(uint256 => mapping(address => uint256)) public _0x89a016;

    IERC721 public _0x5cbda8;
    uint256 public _0xc606f2;

    function _0xdaed4f() external returns (uint256) {
        uint256 _0xaaa097 = ++_0xc606f2;
        return _0xaaa097;
    }

    function _0x697b4f(
        uint256 _0x269c78,
        address _0x8b6261,
        uint256 _0xbf3805
    ) external returns (uint256 _0xf13ba6) {
        IERC20(_0x8b6261)._0xee8201(msg.sender, address(this), _0xbf3805);

        PoolData storage _0x773b30 = _0x8667a9[_0x8b6261];

        if (_0x773b30._0x6e00f6 == 0) {
            _0xf13ba6 = _0xbf3805;
            _0x773b30._0x6e00f6 = _0xbf3805;
        } else {
            _0xf13ba6 =
                (_0xbf3805 * _0x773b30._0x6e00f6) /
                _0x773b30._0xf1f680;
            _0x773b30._0x6e00f6 += _0xf13ba6;
        }

        _0x773b30._0xf1f680 += _0xbf3805;
        _0x6ac733[_0x269c78][_0x8b6261] += _0xf13ba6;

        return _0xf13ba6;
    }

    function _0xa5f49b(
        uint256 _0x269c78,
        address _0x8b6261,
        uint256 _0xadeda2
    ) external returns (uint256 _0xf366c3) {
        require(
            _0x6ac733[_0x269c78][_0x8b6261] >= _0xadeda2,
            "Insufficient shares"
        );

        PoolData storage _0x773b30 = _0x8667a9[_0x8b6261];

        _0xf366c3 =
            (_0xadeda2 * _0x773b30._0xf1f680) /
            _0x773b30._0x6e00f6;

        _0x6ac733[_0x269c78][_0x8b6261] -= _0xadeda2;
        _0x773b30._0x6e00f6 -= _0xadeda2;
        _0x773b30._0xf1f680 -= _0xf366c3;

        IERC20(_0x8b6261).transfer(msg.sender, _0xf366c3);

        return _0xf366c3;
    }

    function _0x26e92f(
        uint256 _0x269c78,
        address _0x8b6261,
        uint256 _0x9124c8
    ) external returns (uint256 _0x54f710) {
        PoolData storage _0x773b30 = _0x8667a9[_0x8b6261];

        _0x54f710 =
            (_0x9124c8 * _0x773b30._0x6e00f6) /
            _0x773b30._0xf1f680;

        require(
            _0x6ac733[_0x269c78][_0x8b6261] >= _0x54f710,
            "Insufficient shares"
        );

        _0x6ac733[_0x269c78][_0x8b6261] -= _0x54f710;
        _0x773b30._0x6e00f6 -= _0x54f710;
        _0x773b30._0xf1f680 -= _0x9124c8;

        IERC20(_0x8b6261).transfer(msg.sender, _0x9124c8);

        return _0x54f710;
    }

    function _0xbc116c(
        uint256 _0x269c78,
        address _0x8b6261
    ) external view returns (uint256) {
        return _0x6ac733[_0x269c78][_0x8b6261];
    }

    function _0x2c88c6(address _0x8b6261) external view returns (uint256) {
        return _0x8667a9[_0x8b6261]._0xf1f680;
    }
}
