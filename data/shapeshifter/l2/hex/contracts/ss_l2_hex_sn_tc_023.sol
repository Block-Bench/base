// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function _0xd155a9(address _0x865e00) external view returns (uint256);

    function transfer(address _0x5e5c3a, uint256 _0x246ea9) external returns (bool);

    function _0x7419c9(
        address from,
        address _0x5e5c3a,
        uint256 _0x246ea9
    ) external returns (bool);
}

interface ICErc20 {
    function _0xb585b9(uint256 _0x246ea9) external returns (uint256);

    function _0x9b13c2(address _0x865e00) external returns (uint256);
}

contract LeveragedVault {
    struct Position {
        address _0xfcf2fc;
        uint256 _0x1960ab;
        uint256 _0xf1c887;
    }

    mapping(uint256 => Position) public _0x15693d;
    uint256 public _0xf1bc90;

    address public _0x6a8ea8;
    uint256 public _0xcf4d14;
    uint256 public _0x06fc33;

    constructor(address _0x5b8b30) {
        _0x6a8ea8 = _0x5b8b30;
        _0xf1bc90 = 1;
    }

    function _0x1e16fa(
        uint256 _0x1cea11,
        uint256 _0xe2d04b
    ) external returns (uint256 _0xc5f304) {
        _0xc5f304 = _0xf1bc90++;

        _0x15693d[_0xc5f304] = Position({
            _0xfcf2fc: msg.sender,
            _0x1960ab: _0x1cea11,
            _0xf1c887: 0
        });

        _0x6797e1(_0xc5f304, _0xe2d04b);

        return _0xc5f304;
    }

    function _0x6797e1(uint256 _0xc5f304, uint256 _0x246ea9) internal {
        Position storage _0x2b8276 = _0x15693d[_0xc5f304];

        uint256 _0xafc0e0;

        if (_0x06fc33 == 0) {
            _0xafc0e0 = _0x246ea9;
        } else {
            _0xafc0e0 = (_0x246ea9 * _0x06fc33) / _0xcf4d14;
        }

        _0x2b8276._0xf1c887 += _0xafc0e0;
        _0x06fc33 += _0xafc0e0;
        _0xcf4d14 += _0x246ea9;

        ICErc20(_0x6a8ea8)._0xb585b9(_0x246ea9);
    }

    function _0xf9381f(uint256 _0xc5f304, uint256 _0x246ea9) external {
        Position storage _0x2b8276 = _0x15693d[_0xc5f304];
        require(msg.sender == _0x2b8276._0xfcf2fc, "Not position owner");

        uint256 _0xcaa560 = (_0x246ea9 * _0x06fc33) / _0xcf4d14;

        require(_0x2b8276._0xf1c887 >= _0xcaa560, "Excessive repayment");

        _0x2b8276._0xf1c887 -= _0xcaa560;
        _0x06fc33 -= _0xcaa560;
        _0xcf4d14 -= _0x246ea9;
    }

    function _0x69c360(
        uint256 _0xc5f304
    ) external view returns (uint256) {
        Position storage _0x2b8276 = _0x15693d[_0xc5f304];

        if (_0x06fc33 == 0) return 0;

        return (_0x2b8276._0xf1c887 * _0xcf4d14) / _0x06fc33;
    }

    function _0x363f0f(uint256 _0xc5f304) external {
        Position storage _0x2b8276 = _0x15693d[_0xc5f304];

        uint256 _0xbe12b5 = (_0x2b8276._0xf1c887 * _0xcf4d14) / _0x06fc33;

        require(_0x2b8276._0x1960ab * 100 < _0xbe12b5 * 150, "Position is healthy");

        _0x2b8276._0x1960ab = 0;
        _0x2b8276._0xf1c887 = 0;
    }
}
