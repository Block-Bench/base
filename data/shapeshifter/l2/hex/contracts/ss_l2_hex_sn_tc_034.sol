// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xe0537f, uint256 _0x03b7c5) external returns (bool);

    function _0x4c280f(
        address from,
        address _0xe0537f,
        uint256 _0x03b7c5
    ) external returns (bool);

    function _0xd22899(address _0x79a975) external view returns (uint256);

    function _0x2aba6d(address _0x96618c, uint256 _0x03b7c5) external returns (bool);
}

interface IUniswapV3Pool {
    function _0x40cbfb(
        address _0xfe5069,
        bool _0x3e27f8,
        int256 _0x91b50d,
        uint160 _0xf047ab,
        bytes calldata data
    ) external returns (int256 _0x9e0349, int256 _0x11e27a);

    function _0xff6621(
        address _0xfe5069,
        uint256 _0x9e0349,
        uint256 _0x11e27a,
        bytes calldata data
    ) external;
}

contract GammaHypervisor {
    IERC20 public _0xc59a27;
    IERC20 public _0x473913;
    IUniswapV3Pool public _0x7fd94a;

    uint256 public _0x83b8de;
    mapping(address => uint256) public _0xd22899;

    struct Position {
        uint128 _0x091403;
        int24 _0xf0e021;
        int24 _0x2f75da;
    }

    Position public _0xda7de8;
    Position public _0x997681;

    function _0xf19c24(
        uint256 _0x737c12,
        uint256 _0x4b5ed1,
        address _0xe0537f
    ) external returns (uint256 _0xdaa9f4) {
        uint256 _0xa96902 = _0xc59a27._0xd22899(address(this));
        uint256 _0x8ffa3e = _0x473913._0xd22899(address(this));

        _0xc59a27._0x4c280f(msg.sender, address(this), _0x737c12);
        _0x473913._0x4c280f(msg.sender, address(this), _0x4b5ed1);

        if (_0x83b8de == 0) {
            _0xdaa9f4 = _0x737c12 + _0x4b5ed1;
        } else {
            uint256 _0x50e50a = _0xa96902 + _0x737c12;
            uint256 _0x30a40b = _0x8ffa3e + _0x4b5ed1;

            _0xdaa9f4 = (_0x83b8de * (_0x737c12 + _0x4b5ed1)) / (_0xa96902 + _0x8ffa3e);
        }

        _0xd22899[_0xe0537f] += _0xdaa9f4;
        _0x83b8de += _0xdaa9f4;

        _0xdd3ea8(_0x737c12, _0x4b5ed1);
    }

    function _0x08ee87(
        uint256 _0xdaa9f4,
        address _0xe0537f
    ) external returns (uint256 _0x9e0349, uint256 _0x11e27a) {
        require(_0xd22899[msg.sender] >= _0xdaa9f4, "Insufficient balance");

        uint256 _0xa96902 = _0xc59a27._0xd22899(address(this));
        uint256 _0x8ffa3e = _0x473913._0xd22899(address(this));

        _0x9e0349 = (_0xdaa9f4 * _0xa96902) / _0x83b8de;
        _0x11e27a = (_0xdaa9f4 * _0x8ffa3e) / _0x83b8de;

        _0xd22899[msg.sender] -= _0xdaa9f4;
        _0x83b8de -= _0xdaa9f4;

        _0xc59a27.transfer(_0xe0537f, _0x9e0349);
        _0x473913.transfer(_0xe0537f, _0x11e27a);
    }

    function _0x881ea9() external {
        _0x61563b(_0xda7de8._0x091403);

        _0xdd3ea8(
            _0xc59a27._0xd22899(address(this)),
            _0x473913._0xd22899(address(this))
        );
    }

    function _0xdd3ea8(uint256 _0x9e0349, uint256 _0x11e27a) internal {}

    function _0x61563b(uint128 _0x091403) internal {}
}
