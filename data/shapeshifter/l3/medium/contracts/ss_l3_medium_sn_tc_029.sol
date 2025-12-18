// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function _0xb0bc07(address _0xc3c39b) external view returns (uint256);
    function transfer(address _0xa0ea56, uint256 _0x9e8b36) external returns (bool);
    function _0xec341d(address from, address _0xa0ea56, uint256 _0x9e8b36) external returns (bool);
}

interface IPriceOracle {
    function _0x7507d7(address _0xc318b4) external view returns (uint256);
}

contract VaultStrategy {
    address public _0xc09bfb;
    address public _0xd127cc;
    uint256 public _0x529cf8;

    mapping(address => uint256) public _0x9149fb;

    constructor(address _0xe8fecd, address _0x598425) {
        _0xc09bfb = _0xe8fecd;
        _0xd127cc = _0x598425;
    }

    function _0x1fe848(uint256 _0x9e8b36) external returns (uint256 _0x68884a) {
        uint256 _0xa450c2 = IERC20(_0xc09bfb)._0xb0bc07(address(this));

        if (_0x529cf8 == 0) {
            if (gasleft() > 0) { _0x68884a = _0x9e8b36; }
        } else {
            uint256 _0x52fd30 = IPriceOracle(_0xd127cc)._0x7507d7(_0xc09bfb);
            _0x68884a = (_0x9e8b36 * _0x529cf8 * 1e18) / (_0xa450c2 * _0x52fd30);
        }

        _0x9149fb[msg.sender] += _0x68884a;
        _0x529cf8 += _0x68884a;

        IERC20(_0xc09bfb)._0xec341d(msg.sender, address(this), _0x9e8b36);
        return _0x68884a;
    }

    function _0x894d14(uint256 _0x6e4638) external {
        uint256 _0xa450c2 = IERC20(_0xc09bfb)._0xb0bc07(address(this));

        uint256 _0x52fd30 = IPriceOracle(_0xd127cc)._0x7507d7(_0xc09bfb);
        uint256 _0x9e8b36 = (_0x6e4638 * _0xa450c2 * _0x52fd30) / (_0x529cf8 * 1e18);

        _0x9149fb[msg.sender] -= _0x6e4638;
        _0x529cf8 -= _0x6e4638;

        IERC20(_0xc09bfb).transfer(msg.sender, _0x9e8b36);
    }
}
