// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function _0x39a2c5(address _0x527b0a) external view returns (uint256);

    function transfer(address _0x7af944, uint256 _0x0ee8c9) external returns (bool);

    function _0x24035d(
        address from,
        address _0x7af944,
        uint256 _0x0ee8c9
    ) external returns (bool);
}

contract LiquidityPool {
    address public _0x72e3fa;
    address public _0xab471e;
    address public _0x15e27a;

    uint256 public _0xa6163c;
    uint256 public _0xaf2fe4;
    uint256 public _0x146ce2;

    bool public _0x739484;

    event Initialized(address _0x72e3fa, address _0x7a239f, address _0x9041a3);

    function _0xa4fba1(
        address _0x9cee85,
        address _0x7b59dd,
        address _0x7aae4e,
        uint256 _0x9725ae
    ) external {
        _0x72e3fa = _0x9cee85;
        _0xab471e = _0x7b59dd;
        _0x15e27a = _0x7aae4e;
        _0xa6163c = _0x9725ae;

        _0x739484 = true;

        emit Initialized(_0x9cee85, _0x7b59dd, _0x7aae4e);
    }

    function _0x93e4c6(uint256 _0xb05426, uint256 _0xc81866) external {
        require(_0x739484, "Not initialized");

        IERC20(_0xab471e)._0x24035d(msg.sender, address(this), _0xb05426);
        IERC20(_0x15e27a)._0x24035d(msg.sender, address(this), _0xc81866);

        _0xaf2fe4 += _0xb05426;
        _0x146ce2 += _0xc81866;
    }

    function _0x6d995c(
        address _0x57eef2,
        address _0xc062bf,
        uint256 _0x2df628
    ) external returns (uint256 _0x6c36d6) {
        require(_0x739484, "Not initialized");
        require(
            (_0x57eef2 == _0xab471e && _0xc062bf == _0x15e27a) ||
                (_0x57eef2 == _0x15e27a && _0xc062bf == _0xab471e),
            "Invalid token pair"
        );

        IERC20(_0x57eef2)._0x24035d(msg.sender, address(this), _0x2df628);

        if (_0x57eef2 == _0xab471e) {
            _0x6c36d6 = (_0x146ce2 * _0x2df628) / (_0xaf2fe4 + _0x2df628);
            _0xaf2fe4 += _0x2df628;
            _0x146ce2 -= _0x6c36d6;
        } else {
            _0x6c36d6 = (_0xaf2fe4 * _0x2df628) / (_0x146ce2 + _0x2df628);
            _0x146ce2 += _0x2df628;
            _0xaf2fe4 -= _0x6c36d6;
        }

        uint256 _0x831d45 = (_0x6c36d6 * _0xa6163c) / 10000;
        _0x6c36d6 -= _0x831d45;

        IERC20(_0xc062bf).transfer(msg.sender, _0x6c36d6);
        IERC20(_0xc062bf).transfer(_0x72e3fa, _0x831d45);

        return _0x6c36d6;
    }

    function _0x8d9d5a() external {
        require(msg.sender == _0x72e3fa, "Only maintainer");

        uint256 _0xddbf39 = IERC20(_0xab471e)._0x39a2c5(address(this));
        uint256 _0x58319d = IERC20(_0x15e27a)._0x39a2c5(address(this));

        if (_0xddbf39 > _0xaf2fe4) {
            uint256 _0xbffdb0 = _0xddbf39 - _0xaf2fe4;
            IERC20(_0xab471e).transfer(_0x72e3fa, _0xbffdb0);
        }

        if (_0x58319d > _0x146ce2) {
            uint256 _0xbffdb0 = _0x58319d - _0x146ce2;
            IERC20(_0x15e27a).transfer(_0x72e3fa, _0xbffdb0);
        }
    }
}
