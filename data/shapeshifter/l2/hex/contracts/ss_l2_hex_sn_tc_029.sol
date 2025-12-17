// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function _0x7c761a(address _0x7001a6) external view returns (uint256);
    function transfer(address _0x8f5b77, uint256 _0x74e45c) external returns (bool);
    function _0x3d26f2(address from, address _0x8f5b77, uint256 _0x74e45c) external returns (bool);
}

interface IPriceOracle {
    function _0x5eee5b(address _0xc7ccfa) external view returns (uint256);
}

contract VaultStrategy {
    address public _0x7fe245;
    address public _0xfa241d;
    uint256 public _0x2eb79a;

    mapping(address => uint256) public _0xf48154;

    constructor(address _0x441231, address _0xac5ed9) {
        _0x7fe245 = _0x441231;
        _0xfa241d = _0xac5ed9;
    }

    function _0xa42c81(uint256 _0x74e45c) external returns (uint256 _0x656e3a) {
        uint256 _0x1faffb = IERC20(_0x7fe245)._0x7c761a(address(this));

        if (_0x2eb79a == 0) {
            _0x656e3a = _0x74e45c;
        } else {
            uint256 _0x3992fd = IPriceOracle(_0xfa241d)._0x5eee5b(_0x7fe245);
            _0x656e3a = (_0x74e45c * _0x2eb79a * 1e18) / (_0x1faffb * _0x3992fd);
        }

        _0xf48154[msg.sender] += _0x656e3a;
        _0x2eb79a += _0x656e3a;

        IERC20(_0x7fe245)._0x3d26f2(msg.sender, address(this), _0x74e45c);
        return _0x656e3a;
    }

    function _0x30ee2a(uint256 _0xbb90c5) external {
        uint256 _0x1faffb = IERC20(_0x7fe245)._0x7c761a(address(this));

        uint256 _0x3992fd = IPriceOracle(_0xfa241d)._0x5eee5b(_0x7fe245);
        uint256 _0x74e45c = (_0xbb90c5 * _0x1faffb * _0x3992fd) / (_0x2eb79a * 1e18);

        _0xf48154[msg.sender] -= _0xbb90c5;
        _0x2eb79a -= _0xbb90c5;

        IERC20(_0x7fe245).transfer(msg.sender, _0x74e45c);
    }
}
