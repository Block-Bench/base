// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xb4b449, uint256 _0x225ff9) external returns (bool);

    function _0x117c2a(
        address from,
        address _0xb4b449,
        uint256 _0x225ff9
    ) external returns (bool);

    function _0x2bd535(address _0x2ce8b5) external view returns (uint256);

    function _0x33134c(address _0x3fdb82, uint256 _0x225ff9) external returns (bool);
}

interface IUniswapV3Pool {
    function _0xd44def(
        address _0xd883b1,
        bool _0x47a2dc,
        int256 _0xf8a319,
        uint160 _0xee08da,
        bytes calldata data
    ) external returns (int256 _0x20e370, int256 _0x8236b5);

    function _0xf6ba7d(
        address _0xd883b1,
        uint256 _0x20e370,
        uint256 _0x8236b5,
        bytes calldata data
    ) external;
}

contract GammaHypervisor {
    IERC20 public _0xe10cc3;
    IERC20 public _0x37d3c4;
    IUniswapV3Pool public _0xf4b129;

    uint256 public _0x55550f;
    mapping(address => uint256) public _0x2bd535;

    struct Position {
        uint128 _0x68d667;
        int24 _0x26b418;
        int24 _0xacdf01;
    }

    Position public _0xb2a21e;
    Position public _0x6aa40a;

    function _0x990c29(
        uint256 _0xfb76f9,
        uint256 _0x3cdb72,
        address _0xb4b449
    ) external returns (uint256 _0x20d9cf) {
        uint256 _0xb508de = _0xe10cc3._0x2bd535(address(this));
        uint256 _0x60a448 = _0x37d3c4._0x2bd535(address(this));

        _0xe10cc3._0x117c2a(msg.sender, address(this), _0xfb76f9);
        _0x37d3c4._0x117c2a(msg.sender, address(this), _0x3cdb72);

        if (_0x55550f == 0) {
            _0x20d9cf = _0xfb76f9 + _0x3cdb72;
        } else {
            uint256 _0xffa017 = _0xb508de + _0xfb76f9;
            uint256 _0xe1c8c0 = _0x60a448 + _0x3cdb72;

            _0x20d9cf = (_0x55550f * (_0xfb76f9 + _0x3cdb72)) / (_0xb508de + _0x60a448);
        }

        _0x2bd535[_0xb4b449] += _0x20d9cf;
        _0x55550f += _0x20d9cf;

        _0x85a37a(_0xfb76f9, _0x3cdb72);
    }

    function _0xb5107e(
        uint256 _0x20d9cf,
        address _0xb4b449
    ) external returns (uint256 _0x20e370, uint256 _0x8236b5) {
        require(_0x2bd535[msg.sender] >= _0x20d9cf, "Insufficient balance");

        uint256 _0xb508de = _0xe10cc3._0x2bd535(address(this));
        uint256 _0x60a448 = _0x37d3c4._0x2bd535(address(this));

        _0x20e370 = (_0x20d9cf * _0xb508de) / _0x55550f;
        _0x8236b5 = (_0x20d9cf * _0x60a448) / _0x55550f;

        _0x2bd535[msg.sender] -= _0x20d9cf;
        _0x55550f -= _0x20d9cf;

        _0xe10cc3.transfer(_0xb4b449, _0x20e370);
        _0x37d3c4.transfer(_0xb4b449, _0x8236b5);
    }

    function _0x42a7da() external {
        _0xf1490d(_0xb2a21e._0x68d667);

        _0x85a37a(
            _0xe10cc3._0x2bd535(address(this)),
            _0x37d3c4._0x2bd535(address(this))
        );
    }

    function _0x85a37a(uint256 _0x20e370, uint256 _0x8236b5) internal {}

    function _0xf1490d(uint128 _0x68d667) internal {}
}
