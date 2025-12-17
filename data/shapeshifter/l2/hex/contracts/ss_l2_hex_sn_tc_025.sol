// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xea6c10, uint256 _0x5c382f) external returns (bool);
    function _0xc5af63(address from, address _0xea6c10, uint256 _0x5c382f) external returns (bool);
}

interface ICompoundToken {
    function _0x50efc4(uint256 _0x5c382f) external;
    function _0x1b7749(uint256 _0x5c382f) external;
    function _0x15008d(uint256 _0xf0f33a) external;
    function _0xc88e8c(uint256 _0x5c382f) external;
}

contract LendingMarket {
    mapping(address => uint256) public _0x49693c;
    mapping(address => uint256) public _0xb1e185;

    address public _0xeb49e0;
    uint256 public _0x641124;

    constructor(address _0xd65b43) {
        _0xeb49e0 = _0xd65b43;
    }

    function _0x50efc4(uint256 _0x5c382f) external {
        _0x49693c[msg.sender] += _0x5c382f;
        _0x641124 += _0x5c382f;

        IERC20(_0xeb49e0).transfer(msg.sender, _0x5c382f);
    }

    function _0x1b7749(uint256 _0x5c382f) external {
        IERC20(_0xeb49e0)._0xc5af63(msg.sender, address(this), _0x5c382f);

        _0x49693c[msg.sender] -= _0x5c382f;
        _0x641124 -= _0x5c382f;
    }
}
