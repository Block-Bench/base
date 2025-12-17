// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function _0x48d87d(address _0x90748f) external view returns (uint256);

    function transfer(address _0x669cf6, uint256 _0xeaaa03) external returns (bool);

    function _0xb0ad0f(
        address from,
        address _0x669cf6,
        uint256 _0xeaaa03
    ) external returns (bool);
}

contract TokenPair {
    address public _0xe315d8;
    address public _0xd4054a;

    uint112 private _0xc540db;
    uint112 private _0xf30679;

    uint256 public constant TOTAL_FEE = 16;

    constructor(address _0x2cf115, address _0xb1b997) {
        _0xe315d8 = _0x2cf115;
        _0xd4054a = _0xb1b997;
    }

    function _0xe45763(address _0x669cf6) external returns (uint256 _0xadbe03) {
        uint256 _0x0330b9 = IERC20(_0xe315d8)._0x48d87d(address(this));
        uint256 _0x725a2c = IERC20(_0xd4054a)._0x48d87d(address(this));

        uint256 _0xf4befc = _0x0330b9 - _0xc540db;
        uint256 _0xf19c40 = _0x725a2c - _0xf30679;

        _0xadbe03 = _0xdafa8b(_0xf4befc * _0xf19c40);

        _0xc540db = uint112(_0x0330b9);
        _0xf30679 = uint112(_0x725a2c);

        return _0xadbe03;
    }

    function _0x3db90d(
        uint256 _0x804fa3,
        uint256 _0x077cad,
        address _0x669cf6,
        bytes calldata data
    ) external {
        require(_0x804fa3 > 0 || _0x077cad > 0, "INSUFFICIENT_OUTPUT_AMOUNT");

        uint112 _0x49941c = _0xc540db;
        uint112 _0xdc4ed6 = _0xf30679;

        require(
            _0x804fa3 < _0x49941c && _0x077cad < _0xdc4ed6,
            "INSUFFICIENT_LIQUIDITY"
        );

        if (_0x804fa3 > 0) IERC20(_0xe315d8).transfer(_0x669cf6, _0x804fa3);
        if (_0x077cad > 0) IERC20(_0xd4054a).transfer(_0x669cf6, _0x077cad);

        uint256 _0x0330b9 = IERC20(_0xe315d8)._0x48d87d(address(this));
        uint256 _0x725a2c = IERC20(_0xd4054a)._0x48d87d(address(this));

        uint256 _0x12bfde = _0x0330b9 > _0x49941c - _0x804fa3
            ? _0x0330b9 - (_0x49941c - _0x804fa3)
            : 0;
        uint256 _0x7b4932 = _0x725a2c > _0xdc4ed6 - _0x077cad
            ? _0x725a2c - (_0xdc4ed6 - _0x077cad)
            : 0;

        require(_0x12bfde > 0 || _0x7b4932 > 0, "INSUFFICIENT_INPUT_AMOUNT");

        uint256 _0x93a132 = _0x0330b9 * 10000 - _0x12bfde * TOTAL_FEE;
        uint256 _0x1a5000 = _0x725a2c * 10000 - _0x7b4932 * TOTAL_FEE;

        require(
            _0x93a132 * _0x1a5000 >=
                uint256(_0x49941c) * _0xdc4ed6 * (1000 ** 2),
            "K"
        );

        _0xc540db = uint112(_0x0330b9);
        _0xf30679 = uint112(_0x725a2c);
    }

    function _0x2a2d35() external view returns (uint112, uint112, uint32) {
        return (_0xc540db, _0xf30679, 0);
    }

    function _0xdafa8b(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
