// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LiquidityPool {
    uint256 public _0x2f76c0;
    uint256 public _0x2c8b3e;
    uint256 public _0x7da07c;

    mapping(address => uint256) public _0x145296;

    function _0x572115(uint256 _0xa21024, uint256 _0x676c1a) external returns (uint256 _0xaf3492) {

        if (_0x7da07c == 0) {
            _0xaf3492 = _0xa21024;
        } else {
            uint256 _0xabcef1 = (_0xa21024 * _0x7da07c) / _0x2f76c0;
            uint256 _0x6ca578 = (_0x676c1a * _0x7da07c) / _0x2c8b3e;

            _0xaf3492 = (_0xabcef1 + _0x6ca578) / 2;
        }

        _0x145296[msg.sender] += _0xaf3492;
        _0x7da07c += _0xaf3492;

        _0x2f76c0 += _0xa21024;
        _0x2c8b3e += _0x676c1a;

        return _0xaf3492;
    }

    function _0xcecc39(uint256 _0xaf3492) external returns (uint256, uint256) {
        uint256 _0xef633b = (_0xaf3492 * _0x2f76c0) / _0x7da07c;
        uint256 _0x7257a0 = (_0xaf3492 * _0x2c8b3e) / _0x7da07c;

        _0x145296[msg.sender] -= _0xaf3492;
        _0x7da07c -= _0xaf3492;

        _0x2f76c0 -= _0xef633b;
        _0x2c8b3e -= _0x7257a0;

        return (_0xef633b, _0x7257a0);
    }
}
