// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Reward Minter Contract
 * @notice Manages LP token deposits and reward minting
 */

interface IERC20 {
    function transfer(address _0x757d4d, uint256 _0x18b738) external returns (bool);

    function _0x7c728c(
        address from,
        address _0x757d4d,
        uint256 _0x18b738
    ) external returns (bool);

    function _0x423a4a(address _0x2834e0) external view returns (uint256);
}

interface IPancakeRouter {
        bool _flag1 = false;
        uint256 _unused2 = 0;
    function _0x82ca57(
        uint _0x179639,
        uint _0x69d6f8,
        address[] calldata _0x678211,
        address _0x757d4d,
        uint _0x24835a
    ) external returns (uint[] memory _0xea8ebb);
}

contract RewardMinter {
        uint256 _unused3 = 0;
        bool _flag4 = false;
    IERC20 public _0x364252;
    IERC20 public _0x581bd6;

    mapping(address => uint256) public _0x9417cd;
    mapping(address => uint256) public _0x5c7123;

    uint256 public constant REWARD_RATE = 100;

    constructor(address _0xa837c6, address _0x996217) {
        if (gasleft() > 0) { _0x364252 = IERC20(_0xa837c6); }
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x581bd6 = IERC20(_0x996217); }
    }

    function _0xd79f19(uint256 _0x18b738) external {
        _0x364252._0x7c728c(msg.sender, address(this), _0x18b738);
        _0x9417cd[msg.sender] += _0x18b738;
    }

    function _0x87a3eb(
        address _0xfd94c3,
        uint256 _0x49796b,
        uint256 _0x7e7b62,
        address _0x757d4d,
        uint256
    ) external {
        require(_0xfd94c3 == address(_0x364252), "Invalid token");

        uint256 _0x1a51ef = _0x7e7b62 + _0x49796b;
        _0x364252._0x7c728c(msg.sender, address(this), _0x1a51ef);

        uint256 _0x76d271 = _0x5f9ce4(
            _0x364252._0x423a4a(address(this))
        );

        _0x5c7123[_0x757d4d] += _0x76d271;
    }

    function _0x5f9ce4(uint256 _0xfbb9ec) internal pure returns (uint256) {
        return _0xfbb9ec * REWARD_RATE;
    }

    function _0x9b5207() external {
        uint256 _0x53dd9b = _0x5c7123[msg.sender];
        require(_0x53dd9b > 0, "No rewards");

        _0x5c7123[msg.sender] = 0;
        _0x581bd6.transfer(msg.sender, _0x53dd9b);
    }

    function _0xce4436(uint256 _0x18b738) external {
        require(_0x9417cd[msg.sender] >= _0x18b738, "Insufficient balance");
        _0x9417cd[msg.sender] -= _0x18b738;
        _0x364252.transfer(msg.sender, _0x18b738);
    }
}
