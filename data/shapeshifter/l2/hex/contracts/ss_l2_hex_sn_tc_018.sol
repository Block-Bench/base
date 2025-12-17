// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function _0x76dc1b(address _0xd580bb) external view returns (uint256);

    function transfer(address _0xc0a3d4, uint256 _0x0e0c70) external returns (bool);
}

contract TokenPool {
    struct Token {
        address _0x46cf73;
        uint256 balance;
        uint256 _0x893005;
    }

    mapping(address => Token) public _0xb474de;
    address[] public _0x623d6f;
    uint256 public _0x971fcb;

    constructor() {
        _0x971fcb = 100;
    }

    function _0xd4c7e0(address _0x8ee31b, uint256 _0xbf85ab) external {
        _0xb474de[_0x8ee31b] = Token({_0x46cf73: _0x8ee31b, balance: 0, _0x893005: _0xbf85ab});
        _0x623d6f.push(_0x8ee31b);
    }

    function _0xb39e25(
        address _0x259810,
        address _0x3ffbcf,
        uint256 _0x6002d7
    ) external returns (uint256 _0xe71834) {
        require(_0xb474de[_0x259810]._0x46cf73 != address(0), "Invalid token");
        require(_0xb474de[_0x3ffbcf]._0x46cf73 != address(0), "Invalid token");

        IERC20(_0x259810).transfer(address(this), _0x6002d7);
        _0xb474de[_0x259810].balance += _0x6002d7;

        _0xe71834 = _0x76be49(_0x259810, _0x3ffbcf, _0x6002d7);

        require(
            _0xb474de[_0x3ffbcf].balance >= _0xe71834,
            "Insufficient liquidity"
        );
        _0xb474de[_0x3ffbcf].balance -= _0xe71834;
        IERC20(_0x3ffbcf).transfer(msg.sender, _0xe71834);

        _0x87ff90();

        return _0xe71834;
    }

    function _0x76be49(
        address _0x259810,
        address _0x3ffbcf,
        uint256 _0x6002d7
    ) public view returns (uint256) {
        uint256 _0xcd8d09 = _0xb474de[_0x259810]._0x893005;
        uint256 _0x2aa767 = _0xb474de[_0x3ffbcf]._0x893005;
        uint256 _0x5ed0f1 = _0xb474de[_0x3ffbcf].balance;

        uint256 _0x4ba1f6 = _0x5ed0f1 * _0x6002d7 * _0x2aa767;
        uint256 _0x0e54d3 = _0xb474de[_0x259810].balance *
            _0xcd8d09 +
            _0x6002d7 *
            _0x2aa767;

        return _0x4ba1f6 / _0x0e54d3;
    }

    function _0x87ff90() internal {
        uint256 _0xefb6d0 = 0;

        for (uint256 i = 0; i < _0x623d6f.length; i++) {
            address _0x8ee31b = _0x623d6f[i];
            _0xefb6d0 += _0xb474de[_0x8ee31b].balance;
        }

        for (uint256 i = 0; i < _0x623d6f.length; i++) {
            address _0x8ee31b = _0x623d6f[i];
            _0xb474de[_0x8ee31b]._0x893005 = (_0xb474de[_0x8ee31b].balance * 100) / _0xefb6d0;
        }
    }

    function _0x43615b(address _0x8ee31b) external view returns (uint256) {
        return _0xb474de[_0x8ee31b]._0x893005;
    }

    function _0xade1c3(address _0x8ee31b, uint256 _0x0e0c70) external {
        require(_0xb474de[_0x8ee31b]._0x46cf73 != address(0), "Invalid token");
        IERC20(_0x8ee31b).transfer(address(this), _0x0e0c70);
        _0xb474de[_0x8ee31b].balance += _0x0e0c70;
        _0x87ff90();
    }
}
