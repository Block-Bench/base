// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Compound Market Token
 * @notice Represents claims on supplied assets
 */

interface IERC20 {
    function transfer(address _0x616f6e, uint256 _0x0fb48f) external returns (bool);

    function _0x4c2045(address _0xafa535) external view returns (uint256);
}

contract CompoundMarket {
    address public _0xd5272e;
    address public _0x6866ee;

    mapping(address => uint256) public _0x9bfdc2;
    uint256 public _0x113090;

    address public constant OLD_TUSD =
        0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
    address public constant NEW_TUSD =
        0x0000000000085d4780B73119b644AE5ecd22b376;

    constructor() {
        _0x6866ee = msg.sender;
        _0xd5272e = OLD_TUSD;
    }

    function _0x6cc41f(uint256 _0x0fb48f) external {
        IERC20(NEW_TUSD).transfer(address(this), _0x0fb48f);
        _0x9bfdc2[msg.sender] += _0x0fb48f;
        _0x113090 += _0x0fb48f;
    }

    function _0xa430f5(address _0xbfd170) external {
        require(_0xbfd170 != _0xd5272e, "Cannot sweep underlying token");

        uint256 balance = IERC20(_0xbfd170)._0x4c2045(address(this));
        IERC20(_0xbfd170).transfer(msg.sender, balance);
    }

    function _0x5df978(uint256 _0x0fb48f) external {
        require(_0x9bfdc2[msg.sender] >= _0x0fb48f, "Insufficient balance");

        _0x9bfdc2[msg.sender] -= _0x0fb48f;
        _0x113090 -= _0x0fb48f;

        IERC20(NEW_TUSD).transfer(msg.sender, _0x0fb48f);
    }
}
