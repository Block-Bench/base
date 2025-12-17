// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x50bde7, uint256 _0x045cf9) external returns (bool);

    function _0xbf7238(
        address from,
        address _0x50bde7,
        uint256 _0x045cf9
    ) external returns (bool);

    function _0x60dcea(address _0x4b8814) external view returns (uint256);

    function _0x1a10f9(address _0x1aee99, uint256 _0x045cf9) external returns (bool);
}

interface IUniswapV3Pool {
    function _0x70991b(
        address _0xd0a709,
        bool _0x3c4236,
        int256 _0xcda5a9,
        uint160 _0xae42ec,
        bytes calldata data
    ) external returns (int256 _0xf38416, int256 _0x5d96d8);

    function _0x9bef80(
        address _0xd0a709,
        uint256 _0xf38416,
        uint256 _0x5d96d8,
        bytes calldata data
    ) external;
}

contract GammaHypervisor {
    IERC20 public _0x8cb825;
    IERC20 public _0x8ce752;
    IUniswapV3Pool public _0xb85386;

    uint256 public _0x0573d1;
    mapping(address => uint256) public _0x60dcea;

    struct Position {
        uint128 _0x9a6706;
        int24 _0x0a04cf;
        int24 _0x3d06a0;
    }

    Position public _0x04c1a1;
    Position public _0x194c65;

    function _0x04d0f8(
        uint256 _0xd31c8e,
        uint256 _0x2cf705,
        address _0x50bde7
    ) external returns (uint256 _0xca1721) {
        uint256 _0x9a2cdd = _0x8cb825._0x60dcea(address(this));
        uint256 _0xaeee76 = _0x8ce752._0x60dcea(address(this));

        _0x8cb825._0xbf7238(msg.sender, address(this), _0xd31c8e);
        _0x8ce752._0xbf7238(msg.sender, address(this), _0x2cf705);

        if (_0x0573d1 == 0) {
            _0xca1721 = _0xd31c8e + _0x2cf705;
        } else {
            uint256 _0x783385 = _0x9a2cdd + _0xd31c8e;
            uint256 _0x17a228 = _0xaeee76 + _0x2cf705;

            _0xca1721 = (_0x0573d1 * (_0xd31c8e + _0x2cf705)) / (_0x9a2cdd + _0xaeee76);
        }

        _0x60dcea[_0x50bde7] += _0xca1721;
        _0x0573d1 += _0xca1721;

        _0x93ed4d(_0xd31c8e, _0x2cf705);
    }

    function _0x6fe308(
        uint256 _0xca1721,
        address _0x50bde7
    ) external returns (uint256 _0xf38416, uint256 _0x5d96d8) {
        require(_0x60dcea[msg.sender] >= _0xca1721, "Insufficient balance");

        uint256 _0x9a2cdd = _0x8cb825._0x60dcea(address(this));
        uint256 _0xaeee76 = _0x8ce752._0x60dcea(address(this));

        _0xf38416 = (_0xca1721 * _0x9a2cdd) / _0x0573d1;
        _0x5d96d8 = (_0xca1721 * _0xaeee76) / _0x0573d1;

        _0x60dcea[msg.sender] -= _0xca1721;
        _0x0573d1 -= _0xca1721;

        _0x8cb825.transfer(_0x50bde7, _0xf38416);
        _0x8ce752.transfer(_0x50bde7, _0x5d96d8);
    }

    function _0xeee86f() external {
        _0x28b8f1(_0x04c1a1._0x9a6706);

        _0x93ed4d(
            _0x8cb825._0x60dcea(address(this)),
            _0x8ce752._0x60dcea(address(this))
        );
    }

    function _0x93ed4d(uint256 _0xf38416, uint256 _0x5d96d8) internal {}

    function _0x28b8f1(uint128 _0x9a6706) internal {}
}
