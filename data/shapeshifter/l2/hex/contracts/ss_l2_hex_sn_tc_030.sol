// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LiquidityPool {
    uint256 public _0x91f35d;
    uint256 public _0x4b7351;
    uint256 public _0xd13f42;

    mapping(address => uint256) public _0x719a11;

    function _0x14848e(uint256 _0x5baaed, uint256 _0x9eda06) external returns (uint256 _0x8a5a99) {

        if (_0xd13f42 == 0) {
            _0x8a5a99 = _0x5baaed;
        } else {
            uint256 _0xc3c02b = (_0x5baaed * _0xd13f42) / _0x91f35d;
            uint256 _0x7932cc = (_0x9eda06 * _0xd13f42) / _0x4b7351;

            _0x8a5a99 = (_0xc3c02b + _0x7932cc) / 2;
        }

        _0x719a11[msg.sender] += _0x8a5a99;
        _0xd13f42 += _0x8a5a99;

        _0x91f35d += _0x5baaed;
        _0x4b7351 += _0x9eda06;

        return _0x8a5a99;
    }

    function _0x9ad07e(uint256 _0x8a5a99) external returns (uint256, uint256) {
        uint256 _0x78ddbb = (_0x8a5a99 * _0x91f35d) / _0xd13f42;
        uint256 _0xbcce52 = (_0x8a5a99 * _0x4b7351) / _0xd13f42;

        _0x719a11[msg.sender] -= _0x8a5a99;
        _0xd13f42 -= _0x8a5a99;

        _0x91f35d -= _0x78ddbb;
        _0x4b7351 -= _0xbcce52;

        return (_0x78ddbb, _0xbcce52);
    }
}
