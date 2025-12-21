// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x5e0489, uint256 _0xdc0962) external returns (bool);
    function _0xeccc90(address from, address _0x5e0489, uint256 _0xdc0962) external returns (bool);
}

interface ICompoundToken {
    function _0x7dc58a(uint256 _0xdc0962) external;
    function _0xd14924(uint256 _0xdc0962) external;
    function _0x7a5b0f(uint256 _0x1f6fce) external;
    function _0xb0e751(uint256 _0xdc0962) external;
}

contract LendingMarket {
    mapping(address => uint256) public _0x008cab;
    mapping(address => uint256) public _0xa81245;

    address public _0x91192d;
    uint256 public _0x195a42;

    constructor(address _0x218ae2) {
        _0x91192d = _0x218ae2;
    }

    function _0x7dc58a(uint256 _0xdc0962) external {
        _0x008cab[msg.sender] += _0xdc0962;
        _0x195a42 += _0xdc0962;

        IERC20(_0x91192d).transfer(msg.sender, _0xdc0962);
    }

    function _0xd14924(uint256 _0xdc0962) external {
        IERC20(_0x91192d)._0xeccc90(msg.sender, address(this), _0xdc0962);

        _0x008cab[msg.sender] -= _0xdc0962;
        _0x195a42 -= _0xdc0962;
    }
}
