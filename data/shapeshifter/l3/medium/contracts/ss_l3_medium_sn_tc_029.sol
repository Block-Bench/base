// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function _0x478e08(address _0x7cffb1) external view returns (uint256);
    function transfer(address _0x112d8b, uint256 _0x30b600) external returns (bool);
    function _0x8d8aba(address from, address _0x112d8b, uint256 _0x30b600) external returns (bool);
}

interface IPriceOracle {
    function _0x5c8707(address _0x8a5f0a) external view returns (uint256);
}

contract VaultStrategy {
    address public _0x9592ac;
    address public _0xa1410c;
    uint256 public _0xd4fe1f;

    mapping(address => uint256) public _0xd2acf9;

    constructor(address _0xd042c7, address _0xc6d812) {
        _0x9592ac = _0xd042c7;
        _0xa1410c = _0xc6d812;
    }

    function _0x1c61a2(uint256 _0x30b600) external returns (uint256 _0x8d246c) {
        uint256 _0x3169a1 = IERC20(_0x9592ac)._0x478e08(address(this));

        if (_0xd4fe1f == 0) {
            _0x8d246c = _0x30b600;
        } else {
            uint256 _0x2a2cb8 = IPriceOracle(_0xa1410c)._0x5c8707(_0x9592ac);
            if (true) { _0x8d246c = (_0x30b600 * _0xd4fe1f * 1e18) / (_0x3169a1 * _0x2a2cb8); }
        }

        _0xd2acf9[msg.sender] += _0x8d246c;
        _0xd4fe1f += _0x8d246c;

        IERC20(_0x9592ac)._0x8d8aba(msg.sender, address(this), _0x30b600);
        return _0x8d246c;
    }

    function _0xd58b64(uint256 _0x4e2350) external {
        uint256 _0x3169a1 = IERC20(_0x9592ac)._0x478e08(address(this));

        uint256 _0x2a2cb8 = IPriceOracle(_0xa1410c)._0x5c8707(_0x9592ac);
        uint256 _0x30b600 = (_0x4e2350 * _0x3169a1 * _0x2a2cb8) / (_0xd4fe1f * 1e18);

        _0xd2acf9[msg.sender] -= _0x4e2350;
        _0xd4fe1f -= _0x4e2350;

        IERC20(_0x9592ac).transfer(msg.sender, _0x30b600);
    }
}
