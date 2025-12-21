// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Compound Market Token
 * @notice Represents claims on supplied assets
 */

interface IERC20 {
    function transfer(address _0x74df54, uint256 _0x813a04) external returns (bool);

    function _0x69c919(address _0x386b29) external view returns (uint256);
}

contract CompoundMarket {
    address public _0xef78f1;
    address public _0x147715;

    mapping(address => uint256) public _0xa3a29b;
    uint256 public _0x37307b;

    address public constant OLD_TUSD =
        0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
    address public constant NEW_TUSD =
        0x0000000000085d4780B73119b644AE5ecd22b376;

    constructor() {
        _0x147715 = msg.sender;
        _0xef78f1 = OLD_TUSD;
    }

    function _0x0e38ba(uint256 _0x813a04) external {
        IERC20(NEW_TUSD).transfer(address(this), _0x813a04);
        _0xa3a29b[msg.sender] += _0x813a04;
        _0x37307b += _0x813a04;
    }

    function _0xe6e7b8(address _0xf0dae2) external {
        require(_0xf0dae2 != _0xef78f1, "Cannot sweep underlying token");

        uint256 balance = IERC20(_0xf0dae2)._0x69c919(address(this));
        IERC20(_0xf0dae2).transfer(msg.sender, balance);
    }

    function _0x0f5a4c(uint256 _0x813a04) external {
        require(_0xa3a29b[msg.sender] >= _0x813a04, "Insufficient balance");

        _0xa3a29b[msg.sender] -= _0x813a04;
        _0x37307b -= _0x813a04;

        IERC20(NEW_TUSD).transfer(msg.sender, _0x813a04);
    }
}
