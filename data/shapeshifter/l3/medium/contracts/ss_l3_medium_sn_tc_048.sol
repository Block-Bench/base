// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x1d5597, uint256 _0x1d39ff) external returns (bool);

    function _0x1d01b1(
        address from,
        address _0x1d5597,
        uint256 _0x1d39ff
    ) external returns (bool);

    function _0x498e08(address _0xc2ff90) external view returns (uint256);
}

contract SonneMarket {
    IERC20 public _0x7e86ea;

    string public _0x3a23e0 = "Sonne WETH";
    string public _0x8a8e29 = "soWETH";
    uint8 public _0xfc2c8d = 8;

    uint256 public _0xf6fcd9;
    mapping(address => uint256) public _0x498e08;

    uint256 public _0x9498ce;
    uint256 public _0x66c858;

    event Mint(address _0x3e6ab1, uint256 _0xae288f, uint256 _0x781b64);
    event Redeem(address _0x6f7eda, uint256 _0xf931d9, uint256 _0xdc3bfb);

    constructor(address _0xc1f9de) {
        _0x7e86ea = IERC20(_0xc1f9de);
    }

    function _0xbd363e() public view returns (uint256) {
        if (_0xf6fcd9 == 0) {
            return 1e18;
        }

        uint256 _0x419ac6 = _0x7e86ea._0x498e08(address(this));

        uint256 _0xf83c1e = _0x419ac6 + _0x9498ce - _0x66c858;

        return (_0xf83c1e * 1e18) / _0xf6fcd9;
    }

    function _0xbafdf8(uint256 _0xae288f) external returns (uint256) {
        require(_0xae288f > 0, "Zero mint");

        uint256 _0x39c43f = _0xbd363e();

        uint256 _0x781b64 = (_0xae288f * 1e18) / _0x39c43f;

        _0xf6fcd9 += _0x781b64;
        _0x498e08[msg.sender] += _0x781b64;

        _0x7e86ea._0x1d01b1(msg.sender, address(this), _0xae288f);

        emit Mint(msg.sender, _0xae288f, _0x781b64);
        return _0x781b64;
    }

    function _0x2b21e3(uint256 _0xdc3bfb) external returns (uint256) {
        require(_0x498e08[msg.sender] >= _0xdc3bfb, "Insufficient balance");

        uint256 _0x39c43f = _0xbd363e();

        uint256 _0xf931d9 = (_0xdc3bfb * _0x39c43f) / 1e18;

        _0x498e08[msg.sender] -= _0xdc3bfb;
        _0xf6fcd9 -= _0xdc3bfb;

        _0x7e86ea.transfer(msg.sender, _0xf931d9);

        emit Redeem(msg.sender, _0xf931d9, _0xdc3bfb);
        return _0xf931d9;
    }

    function _0x7299d3(
        address _0xc2ff90
    ) external view returns (uint256) {
        uint256 _0x39c43f = _0xbd363e();

        return (_0x498e08[_0xc2ff90] * _0x39c43f) / 1e18;
    }
}
