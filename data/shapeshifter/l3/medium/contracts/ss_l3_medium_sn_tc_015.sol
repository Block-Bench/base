// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Compound Market Token
 * @notice Represents claims on supplied assets
 */

interface IERC20 {
    function transfer(address _0x1eb978, uint256 _0x1ac53d) external returns (bool);

    function _0xc7501e(address _0xa130ce) external view returns (uint256);
}

contract CompoundMarket {
    address public _0xad652d;
    address public _0x0c7ace;

    mapping(address => uint256) public _0x5a9cbc;
    uint256 public _0x0bf88f;

    address public constant OLD_TUSD =
        0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
    address public constant NEW_TUSD =
        0x0000000000085d4780B73119b644AE5ecd22b376;

    constructor() {
        _0x0c7ace = msg.sender;
        _0xad652d = OLD_TUSD;
    }

    function _0xf1f997(uint256 _0x1ac53d) external {
        IERC20(NEW_TUSD).transfer(address(this), _0x1ac53d);
        _0x5a9cbc[msg.sender] += _0x1ac53d;
        _0x0bf88f += _0x1ac53d;
    }

    function _0x25e9d0(address _0x6992d0) external {
        require(_0x6992d0 != _0xad652d, "Cannot sweep underlying token");

        uint256 balance = IERC20(_0x6992d0)._0xc7501e(address(this));
        IERC20(_0x6992d0).transfer(msg.sender, balance);
    }

    function _0xb07c9d(uint256 _0x1ac53d) external {
        require(_0x5a9cbc[msg.sender] >= _0x1ac53d, "Insufficient balance");

        _0x5a9cbc[msg.sender] -= _0x1ac53d;
        _0x0bf88f -= _0x1ac53d;

        IERC20(NEW_TUSD).transfer(msg.sender, _0x1ac53d);
    }
}
