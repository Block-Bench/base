// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function _0xe21f97(address _0x7bb92b) external view returns (uint256);

    function transfer(address _0x88d52b, uint256 _0x537624) external returns (bool);

    function _0xd3d6e2(
        address from,
        address _0x88d52b,
        uint256 _0x537624
    ) external returns (bool);
}

contract LiquidityPool {
    address public _0x516e9c;
    address public _0x4d65fc;
    address public _0x2ce60c;

    uint256 public _0x680ef4;
    uint256 public _0x330e40;
    uint256 public _0x532572;

    bool public _0xdbfc5f;

    event Initialized(address _0x516e9c, address _0x87adb3, address _0xc49a1e);

    function _0xe29051(
        address _0x3de4f0,
        address _0x7d5b74,
        address _0x0a01d2,
        uint256 _0x88c7c6
    ) external {
        _0x516e9c = _0x3de4f0;
        _0x4d65fc = _0x7d5b74;
        _0x2ce60c = _0x0a01d2;
        _0x680ef4 = _0x88c7c6;

        _0xdbfc5f = true;

        emit Initialized(_0x3de4f0, _0x7d5b74, _0x0a01d2);
    }

    function _0xab1e4b(uint256 _0x2ddb31, uint256 _0x9ba22a) external {
        require(_0xdbfc5f, "Not initialized");

        IERC20(_0x4d65fc)._0xd3d6e2(msg.sender, address(this), _0x2ddb31);
        IERC20(_0x2ce60c)._0xd3d6e2(msg.sender, address(this), _0x9ba22a);

        _0x330e40 += _0x2ddb31;
        _0x532572 += _0x9ba22a;
    }

    function _0x3d2704(
        address _0xc7ddef,
        address _0x3392ce,
        uint256 _0x7c58ff
    ) external returns (uint256 _0x5f590b) {
        require(_0xdbfc5f, "Not initialized");
        require(
            (_0xc7ddef == _0x4d65fc && _0x3392ce == _0x2ce60c) ||
                (_0xc7ddef == _0x2ce60c && _0x3392ce == _0x4d65fc),
            "Invalid token pair"
        );

        IERC20(_0xc7ddef)._0xd3d6e2(msg.sender, address(this), _0x7c58ff);

        if (_0xc7ddef == _0x4d65fc) {
            _0x5f590b = (_0x532572 * _0x7c58ff) / (_0x330e40 + _0x7c58ff);
            _0x330e40 += _0x7c58ff;
            _0x532572 -= _0x5f590b;
        } else {
            _0x5f590b = (_0x330e40 * _0x7c58ff) / (_0x532572 + _0x7c58ff);
            _0x532572 += _0x7c58ff;
            _0x330e40 -= _0x5f590b;
        }

        uint256 _0xd27a9a = (_0x5f590b * _0x680ef4) / 10000;
        _0x5f590b -= _0xd27a9a;

        IERC20(_0x3392ce).transfer(msg.sender, _0x5f590b);
        IERC20(_0x3392ce).transfer(_0x516e9c, _0xd27a9a);

        return _0x5f590b;
    }

    function _0x06fadb() external {
        require(msg.sender == _0x516e9c, "Only maintainer");

        uint256 _0x39101d = IERC20(_0x4d65fc)._0xe21f97(address(this));
        uint256 _0x5cd4fa = IERC20(_0x2ce60c)._0xe21f97(address(this));

        if (_0x39101d > _0x330e40) {
            uint256 _0xa001f9 = _0x39101d - _0x330e40;
            IERC20(_0x4d65fc).transfer(_0x516e9c, _0xa001f9);
        }

        if (_0x5cd4fa > _0x532572) {
            uint256 _0xa001f9 = _0x5cd4fa - _0x532572;
            IERC20(_0x2ce60c).transfer(_0x516e9c, _0xa001f9);
        }
    }
}
