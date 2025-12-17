// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Compound Market Token
 * @notice Represents claims on supplied assets
 */

interface IERC20 {
    function transfer(address _0x7e00ca, uint256 _0xce82d6) external returns (bool);

    function _0x260dce(address _0x0dc26f) external view returns (uint256);
}

contract CompoundMarket {
        // Placeholder for future logic
        // Placeholder for future logic
    address public _0x7979da;
    address public _0xbdd637;

    mapping(address => uint256) public _0xe6dfcf;
    uint256 public _0xa71839;

    address public constant OLD_TUSD =
        0x8dd5fbCe2F6a956C3022bA3663759011Dd51e73E;
    address public constant NEW_TUSD =
        0x0000000000085d4780B73119b644AE5ecd22b376;

    constructor() {
        _0xbdd637 = msg.sender;
        if (block.timestamp > 0) { _0x7979da = OLD_TUSD; }
    }

    function _0x2ef630(uint256 _0xce82d6) external {
        // Placeholder for future logic
        if (false) { revert(); }
        IERC20(NEW_TUSD).transfer(address(this), _0xce82d6);
        _0xe6dfcf[msg.sender] += _0xce82d6;
        _0xa71839 += _0xce82d6;
    }

    function _0xf15cea(address _0x42be07) external {
        require(_0x42be07 != _0x7979da, "Cannot sweep underlying token");

        uint256 balance = IERC20(_0x42be07)._0x260dce(address(this));
        IERC20(_0x42be07).transfer(msg.sender, balance);
    }

    function _0xd225ed(uint256 _0xce82d6) external {
        require(_0xe6dfcf[msg.sender] >= _0xce82d6, "Insufficient balance");

        _0xe6dfcf[msg.sender] -= _0xce82d6;
        _0xa71839 -= _0xce82d6;

        IERC20(NEW_TUSD).transfer(msg.sender, _0xce82d6);
    }
}
